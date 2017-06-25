(in-package #:com.markmywords.serve)

;;(declaim (optimize debug))
(declaim (optimize speed))

(defparameter *user-cookie* (concatenate 'string *app-prefix* "-" "user"))
(defparameter *auth-cookie* (concatenate 'string *app-prefix* "-" "auth"))
(defparameter *flag-cookie* (concatenate 'string *app-prefix* "-" "flag"))

(defun try-persisted-login ()
  #+server-debug
  (format t "Session: ~A ~A Cookie: ~A~%"
          (session-value 'user-idx)
          (session-value 'username)
          (cookie-in *flag-cookie*))
  (unless (and (session-value 'user-idx)
               (session-value 'username))
    (when (string= (cookie-in *flag-cookie*) "t")
      #+server-debug(format t "Found flag.~%")
      (let* ((persisted-user (cookie-in *user-cookie*))
			 (persisted-auth (cookie-in *auth-cookie*))
			 (generated-auth (make-digest persisted-user *app-prefix*)))
        (declare (type string persisted-user persisted-auth generated-auth))
		#+server-debug
        (progn
		  (format t "Found persisted user: ~A~%" persisted-user)
		  (format t "Compare digests:~%~A~%~A~%" persisted-auth generated-auth))
		(when (string= persisted-auth generated-auth)
          (login (get-mmy-user persisted-user))))))
  #+server-debug(format t "User-idx: ~A~%" (session-value 'user-idx)))

(defun try-login (username password persist)
  (declare (type string username password persist))
  #+server-debug(format t "Try login: ~A~%" username)
  (let* ((user (get-mmy-user username))
		 (result
		  (cond
			((= (length username) 0)
			 '((:fail . "Missing username")))
			((= (length password) 0)
			 '((:fail . "Missing password")))
            ((or (null user)
                 (string-not-equal password (password user)))
             '((:fail . "Incorrect login")))
			(t
			 (login user persist)
			 (get-user-info-alist)))))
    result))

(defun login (user &optional (persist ""))
  (declare (type mmy-user user) (type string persist))
  (when (and (boundp '*request*) user)
    #+server-debug(format t "Logging in user: ~A~%" (username user))
    (when (string= persist "on")
      (persist-login user))
    (setup-session user)))

(defun persist-login (user)
  (declare (type mmy-user user))
  (let ((username (username user)))
    (declare (type string username))
    (multiple-value-bind (dig exp) (make-digest username *app-prefix*)
      (declare (type string dig) (type integer exp))
      (set-cookie *user-cookie* :value username :expires exp)
      (set-cookie *auth-cookie* :value dig :expires exp)
      (set-cookie *flag-cookie* :value "t" :expires exp))))

(defun make-digest (username &optional (seed "seed"))
  (declare (type string username seed))
  (values (hunchentoot::md5-hex (format nil "~A:~A:2weeks" username seed))
		  (+ (get-universal-time) (* 2 7 24 60 60))))

(defun logout ()
  #+server-debug(format t "Logging out. ~%")
  (clear-session)
  (clear-cookies))

;;; app-specific session setup

(defun setup-session (user)
  (declare (type mmy-user user))
  #+server-debug(format t "Setup session for: ~A (~A)~%" user (idx user))
  (when user
    (setf (session-value 'user-idx) (idx user)
          (session-value 'username) (username user)
          (session-value 'admin) (adminp user))))

(defun get-user-info-alist ()
  (if (boundp '*request*)
      (when (session-value 'user-idx)
		(list (cons :idx (session-value 'user-idx))
			  (cons :username (session-value 'username))
			  (cons :admin (session-value 'admin))))
      '((:username . "admin") (:idx . 1) (:admin . 1))))

(defun get-current-user-idx ()
  (if (boundp '*request*)
      (session-value 'user-idx)
      1))

(defun clear-session ()
  (delete-session-value 'user-idx)
  (delete-session-value 'username)
  (delete-session-value 'admin))

(defun clear-cookies ()
  (set-cookie *flag-cookie*)
  (set-cookie *user-cookie*)
  (set-cookie *auth-cookie*))
