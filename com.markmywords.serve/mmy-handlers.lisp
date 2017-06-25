(in-package #:com.markmywords.serve)

;;(declaim (optimize debug))
(declaim (optimize speed))

(define-easy-handler (handle-home :uri "/") ()
  (no-cache)
  (try-persisted-login)
  (handle-static-file "pub/xhtml/x.xhtml"))

(define-easy-handler (handle-logout :uri "/logout") ()
  (logout)
  (redirect "/"))

(define-easy-handler (handle-admin :uri "/admin") ()
  (no-cache)
  (try-persisted-login)
  (if (= (cdr (assoc :admin (get-user-info-alist))) 1)
      (handle-static-file "pub/xhtml/a.xhtml")
      (redirect "/")))

(define-resource-gettable-json "login"
    (lambda () (format nil (encode-json-to-string (get-user-info-alist)))))

(define-resource-settable-json "login"
    (lambda (username password persist)
      (format nil (encode-json-to-string (try-login username password persist))))
  (username password persist))

(define-resource-gettable-json "user"
    (lambda () (format nil (encode-json-to-string (get-user-info-alist)))))

(defparameter *categories*
  (list "General" "Sports" "Politics" "Entertainment" "Technology"))

(define-resource-gettable-json "categories"
    (lambda () (format nil (encode-json-to-string *categories*))))

(defun create-entry (words title category)
  (let ((my-user (db:get-mmy-user-by-idx (get-current-user-idx))))
    (add-entry words category title)))

(define-resource-gettable-json "entry"
    (lambda (words title category n pop)
      (declare (ignorable words title category n pop))
      (cond
        ((and n pop)
         (format nil (encode-json-to-string (get-popular-entries n))))
        (pop
         (format nil (encode-json-to-string (entry-to-alist (get-most-popular-entry)))))
        (t
         (format nil (encode-json-to-string (mapcar #'entry-to-alist (get-entries words title category)))))))
  ((words :init-form "")
   (title :init-form "")
   (category :init-form "")
   (n :parameter-type 'integer)
   pop))

(define-resource-get-one-json "entry"
    (lambda (id)
      (format nil (encode-json-to-string (entry-to-alist (get-one-mmy-words id))))))

(define-resource-settable-json "entry"
    (lambda (words title category)
      (format nil (encode-json-to-string (mapcar #'entry-to-alist (list (create-entry words title category))))))
  (words title category))

(define-resource-deletable-json "entry"
    (lambda (id words title category up dn)
      (declare (ignorable words title category up dn))
      (app:delete-entry id)
      (format nil (encode-json-to-string (mapcar #'entry-to-alist (get-entries "" "" "")))))
  (words title category up dn))

(define-resource-puttable-json "entry"
    (lambda (id words title category up dn verified)
      (declare (ignorable words title category up dn verified))
      (cond
        ((> (length verified) 0)
         (app::set-entry-verified id (parse-integer verified :junk-allowed t)))
        (t
         (when (string-not-equal words "")
		   (let ((entry (get-one-mmy-words id)))
			 (setf (content entry) words)
			 (db:save-mmy-words entry)))))
      (format nil (encode-json-to-string (entry-to-alist (get-one-mmy-words id)))))
  (words title category up dn verified))

(define-resource-procedure-json "upvote"
    (lambda (id)
      (rank-entry 'app:up (get-current-user-idx) id)
      (format nil (encode-json-to-string (mapcar #'entry-to-alist (list (get-one-mmy-words id))))))
  (id))

(define-resource-procedure-json "dnvote"
    (lambda (id)
      (rank-entry 'app:dn (get-current-user-idx) id)
      (format nil (encode-json-to-string (mapcar #'entry-to-alist (list (get-one-mmy-words id))))))
  (id))

(define-resource-gettable-json "rank-map"
    (lambda () (format nil (encode-json-to-string (db::get-user-ranked-words (get-current-user-idx))))))

(define-resource-gettable-json "profile"
    (lambda () (format nil (encode-json-to-string (get-user-info-alist)))))

(define-resource-settable-json "profile"
    (lambda (username password)
	  (let (result)
		(handler-case
			(add-user-profile username password)
		  (condition (c) (declare (ignorable c))
					 (setf result (list (cons :fail "exists")))))
		(unless result
		  (setf result (get-user-info-alist))
		  (login (get-mmy-user username)))
		(format nil (encode-json-to-string result))))
  (username password))

(define-resource-puttable-json "profile"
    (lambda (id username password)
      (let (result)
		(handler-case
			(update-user-profile id username password)
		  (condition (c) (declare (ignorable c))
					 (setf result (list (cons :fail "exists")))))
		(unless result
		  (setf result (get-user-info-alist))
		  (login (get-mmy-user username)))
		(format nil (encode-json-to-string result))))
  (username password))

(defun get-all-xusers (&optional name pass admin)
  (declare (ignorable name pass admin))
  ;; Must downcase the html table or it
  ;; is not rendered correctly in Safari.
  (string-downcase (users-objects->html (db:get-mmy-users))))

(defun create-xuser (&optional name pass admin)
  (declare (ignorable name pass admin)))

(defun get-xuser (id name pass admin accuracy resource-action)
  (declare (ignorable id name pass admin accuracy resource-action)))

(defun update-xuser (id name pass admin accuracy resource-action)
  (declare (ignorable id name pass admin accuracy resource-action)))

(defun delete-xuser (id name pass admin accuracy resource-action)
  (declare (ignorable id name pass admin accuracy resource-action)))

(define-resource-html "xuser" get-all-xusers (name pass admin))

;;; Initialize dispatch table --------------------------------------------------

(setf *dispatch-table*
      (nconc							; Remember: like @ splice

       ;; simple handlers (mostly for forms)
       (list 'dispatch-easy-handlers)

       ;; folders - need trailing slash
       (mapcar (lambda (args)
				 (apply #'create-folder-dispatcher-and-handler args))
			   `( ;; folders for content and other web files
				 ("/images/" "pub/images/")
				 ("/style/" "pub/style/")
				 ("/js/" "pub/js/")))))

;;; Web server entry points ----------------------------------------------------

(defclass debuggable-acceptor (hunchentoot:easy-acceptor) ())

#- (and)
(defmethod hunchentoot:acceptor-request-dispatcher ((*acceptor* debuggable-acceptor))
  (if *catch-errors-p*
      (call-next-method)
      (let ((dispatcher (handler-bind ((error #'invoke-debugger))
                          (call-next-method))))
        (lambda (request)
          (handler-bind ((error #'invoke-debugger))
            (funcall dispatcher request))))))

#- (and)
(defmethod hunchentoot:process-connection ((*acceptor* debuggable-acceptor) (socket t))
  (declare (ignore socket))
  (handler-bind ((error #'invoke-debugger))
    (call-next-method)))

(defun mmy-web-start ()
  "Start the server."
  (setf *message-log-pathname* "log/messagelog"
        *access-log-pathname* "log/accesslog"
        *session-secret* (reset-session-secret)
        *mmy-server* (make-instance 'debuggable-acceptor :port +server-port+))
  (format t "; --> Starting...~%")
  (start *mmy-server*)
  (format t "; --> Ready!~%"))

(defun mmy-web-stop ()
  "Stop mark-my-words web application.
Stop Hunchentoot and disconnect from the database."
  (format t "; --> Stopping...~%")
  (restart-case
	  (hunchentoot:stop *mmy-server*)
	(ignore-simple-error (c)
	  (format t "STOP-LISTENING error ignored: ~A~%" (type-of c)))
	(ignore-unbound-slot (c)
	  (format t "STOP-LISTENING error ignored: ~A~%" (type-of c)))
	(ignore-shutdown-condition (c)
	  (format t "STOP-LISTENING error ignored: ~A~%" (type-of c))))
  (format t "; --> Stopped.~%"))
