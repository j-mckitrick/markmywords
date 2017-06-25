(in-package #:com.markmywords.serve)

;;(declaim (optimize debug))
(declaim (optimize speed))

(defun rest-url-p (request method uri-pattern)
  "Test if REQUEST url matches 'REST' METHOD and URI-PATTERN."
  (declare (ignore request))
  (and (string= method (request-method*))
       (scan uri-pattern (request-uri*))))

(defun words-idx-fn (words-idx)
  (if (db::get-user-words-mapping (get-current-user-idx) words-idx) 0 1))

;; Data conversion functions ---------------------------------------------------

(defun entry-to-alist (entry)
  "Convert a words ENTRY to an alist."
  (list (cons :idx (idx entry))
        (cons :username (username (user entry)))
        (cons :date (first
                     (split-sequence:split-sequence
                      #\Space (clsql-sys:format-date nil (date entry)))))
        (cons :category (category entry))
        (cons :title (title entry))
        (cons :content (content entry))
        (cons :up (up-votes entry))
        (cons :dn (dn-votes entry))
        (cons :verified (verified entry))
        (cons :accuracy (format nil "~,2F / ~A"
                                (* (accuracy (user entry)) 100)
                                (length (get-mmy-words-for-user (user entry)))))
        (cons :rankable (words-idx-fn (idx entry)))))

#+nil
(defun words-objects->xml (objects &optional word-idx-fn)
  (wrap-as-xml-result
    (with-tag ("words" `(("xmlns:xlink" "http://www.w3.org/1999/xlink")))
      (mapc (lambda (w)
			  (let ((date
					 (first
					  (split-sequence:split-sequence
					   #\Space (clsql-sys:format-date nil (date w))))))
				(simple-tag "word" (content w)
							`(("idx" ,(idx w))
							  ("xlink:href" "/entry")
							  ("date" ,date)
							  ("category" ,(category w))
							  ("title" ,(title w))
							  ("up" ,(up-votes w))
							  ("dn" ,(dn-votes w))
							  ("user" ,(username (user w)))
							  ("verified" ,(verified w))
							  ("rankable" ,(if (functionp word-idx-fn) (funcall word-idx-fn (idx w)) "false"))))))
			objects))))

#+nil
(defun users-objects->xml (users)
  (wrap-as-xml-result
    (with-tag ("users")
      (mapc (lambda (user)
			  (simple-tag "user" (username user)
						  `(("idx" ,(idx user)))))
			users))))

(defun users-objects->html (users)
  (wrap-as-html-result
	(with-tag ("table")
	  (with-tag (:tbody)
		(with-tag (:tr)
		  (dolist (col '("username" "password" "admin" "accuracy"))
			(simple-tag :th col)))
		(dolist (user users)
          (with-tag (:tr)
			(simple-tag "td" (username user))
			(simple-tag "td" (password user))
			;;(simple-tag "td" (adminp user))
            (with-tag (:td)
              (simple-tag "input" "" `(("type" "checkbox")
                                       ("id" ,(format nil "cb-admin_~A" (idx user)))
                                       ,(if (> (adminp user) 0) '("checked" "checked") '("c" "d"))
                                       ("onclick" "Admin.doadmin();"))))
			(simple-tag "td" (format nil "~,2F" (* (accuracy user) 100)))))))))

#+nil
(defun query->xml (query &key (root-tag "words") (row-tag "word"))
  "Convert a database QUERY (rows cols) into a basic xml structure.
RETURNS: xml."
  (assert query)
  (destructuring-bind (rows cols) query
    (wrap-as-xml-result
      (with-tag (root-tag)
		(dolist (row rows)
		  (with-tag (row-tag)
			(mapc #'simple-tag cols row)))))))
