(in-package #:com.markmywords.app)

;;(declaim (optimize debug))
(declaim (optimize speed))

(defparameter my-user nil)

(defun get-entries (&optional (words "") (title "") (category ""))
  "Get words entries, either all, queried, or by popularity."
  #+server-debug(format t "get-entries: ~A ~A ~A~%" words title category)
  (if
   (or (> (length words) 0)
	   (> (length title) 0)
	   (> (length category) 0))
   (db:search-mmy-words
	:title title
	:category category
	:content words)
   (db:get-mmy-words)))

(defun get-popular-entries (n)
  "Returns list of alists, not words objects."
  (multiple-value-bind (rows cols)
      (get-popular-mmy-words-n n)
    (mapcar (lambda (row) (mapcar #'cons cols row)) rows)))

(defun get-most-popular-entry ()
  "Returns one entry."
  (get-popular-mmy-words))

(defun get-one-entry (id)
  (list (db:get-one-mmy-words id)))

(defun add-entry (words category title)
  "Add a new words entry."
  #+server-debug
  (progn
    (format t "Got title: ~A~%" title)
    (format t "Got new words: ~A~%" words)
    (format t "Category: ~A~%" category))
  (let ((entry (db:add-mmy-words my-user words category title)))
    (update-accuracy my-user)
    entry))

#- (and)
(defun update-entry (id pass)
  (let ((user (get-mmy-user-by-idx id)))
	(setf (password user) pass)
	(sb-thread:with-mutex (db::*db-lock*)
	  (clsql:update-record-from-slots user '(password)))))

#- (and)
(defun upvote-entry (id)
  "Upvote an entry."
  (let ((words (get-one-mmy-words id)))
	(incf (up-votes words))
	(list (db:update-mmy-words-rank words))))

#- (and)
(defun dnvote-entry (id)
  "Downvote an entry."
  (let ((words (get-one-mmy-words id)))
	(incf (dn-votes words))
	(list (db:update-mmy-words-rank words))))

(defun rank-entry (vote user-idx words-idx)
  (let ((words (get-one-mmy-words words-idx)))
    (unless (db::get-user-words-mapping user-idx words-idx)
	  (ecase vote
		(up (incf (up-votes words)))
		(dn (incf (dn-votes words))))
	  (add-user-words-mapping user-idx words-idx))
	(list (update-mmy-words-rank words))))

(defun set-entry-verified (words-idx verified)
  (let ((words (get-one-mmy-words words-idx)))
    (setf (verified words) verified)
    (db:save-mmy-words words)
    (update-accuracy (user words))))

(defun update-accuracy (user)
  (let* ((words-count (length (get-mmy-words-for-user user)))
         (words-count-verified (length (get-verified-mmy-words-for-user user)))
         (accuracy (/ words-count-verified words-count)))
    #+server-debug(format t "V: ~A T: ~A A: ~A~%" words-count-verified words-count accuracy)
    (setf (accuracy user) (float accuracy))
    (db:save-mmy-user user)))

(defun delete-entry (id)
  (let* ((entry (db:get-one-mmy-words id))
         (user (user entry)))
    (db:delete-mmy-words entry)
    (update-accuracy user)))

(defun get-user-profile (id)
  (db:get-mmy-user id))

(defun add-user-profile (username password)
  (when (db:get-mmy-user username)
	(error "User exists."))
  (let ((user (make-instance 'mmy-user :username username :password password)))
	(db:save-mmy-user user)))

(defun update-user-profile (id username password)
  (let ((user (db:get-mmy-user-by-idx id)))
	(setf (username user) username)
	(setf (password user) password)
	(db:save-mmy-user user)))

(defun get-users ()
  (get-mmy-users))
