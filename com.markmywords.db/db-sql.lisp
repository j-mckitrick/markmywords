(in-package #:com.markmywords.db)

;;(declaim (optimize debug))
(declaim (optimize speed))

(defvar *db-lock* (sb-thread:make-mutex :name "db-lock"))

(defun connect-to-mmy ()
  "Connect to mmy database, set some options."
  (clsql:connect '("localhost" "mmy" "jcm" "none")
				 :database-type :postgresql)
  #+db-debug(format t "; --> Connected to db.~%"))

(defun disconnect-from-mmy ()
  "Disconnect from database."
  (clsql:disconnect))

(clsql:locally-enable-sql-reader-syntax)

(defun get-mmy-users ()
  "Get all users."
  (with-mutex (*db-lock*)
    (clsql:select 'mmy-user :flatp t :refresh t :order-by [idx])))

(defun search-mmy-words (&key (title "") (category "") (content ""))
  "Search words for matches."
  (format t "Searching~%")
  (get-mmy-words :title (format nil "%~A%" title)
				 :category (format nil "%~A%" category)
				 :content (format nil "%~A%" content)))

(defun get-mmy-words (&key (title "%") (category "%") (content "%"))
  "Get all words predictions."
  #+db-debug(format t "Getting~%")
  (with-mutex (*db-lock*)
    (let ((*default-caching* nil))
      (clsql:select 'mmy-entry :caching nil :flatp t :refresh t :order-by [idx]
					:where
					[and
					[uplike [category] category]
					[uplike [title] title]
					[uplike [content] content]
					]))))

(defun get-popular-mmy-words ()
  "Get most popular mmy-words by total vote count.  Not OO."
  (get-one-mmy-words
   (caar
    (with-mutex (*db-lock*)
      (query
       (concatenate 'string
                    "SELECT idx FROM mmy_entry WHERE (up_votes - down_votes) = "
                    "(SELECT MAX(up_votes - down_votes) FROM mmy_entry)")
       :field-names nil)))))

(defun get-popular-mmy-words-n (n)
  "Get most popular mmy-words by total vote count.  Not OO."
  (let ((sql (concatenate 'string
						  "SELECT w.*, u.username "
						  "FROM mmy_entry AS w, mmy_user AS u "
						  "WHERE w.user_idx = u.idx "
						  "ORDER BY (w.up_votes - w.down_votes) DESC LIMIT ~A")))
	(with-mutex (*db-lock*)
      (query (format nil sql n)))))

(defun get-mmy-words-for-user (user)
  "Get entries for USER."
  (with-mutex (*db-lock*)
    (let ((*default-caching* nil))
      (clsql:select 'mmy-entry
                    :caching nil
                    :flatp t
                    :refresh t
                    :order-by [idx]
                    :where
                    [= [slot-value 'mmy-entry 'user_idx] (idx user)]
                    ))))

(defun get-verified-mmy-words-for-user (user)
  "Get entries for USER."
  (with-mutex (*db-lock*)
    (let ((*default-caching* nil))
      (clsql:select 'mmy-entry
                    :caching nil
                    :flatp t
                    :refresh t
                    :order-by [idx]
                    :where
                    [and
                    [= [slot-value 'mmy-entry 'user_idx] (idx user)]
                    [= [slot-value 'mmy-entry 'verified] 1]
                    ]
                    ))))

(defun get-one-mmy-words (idx)
  "Get one words predictions."
  (with-mutex (*db-lock*)
    (car
     (clsql:select 'mmy-entry
				   :flatp t
				   :refresh t
				   :where
				   [= [slot-value 'mmy-entry 'idx] idx]))))

(defun delete-mmy-words (words)
  "Delete words with ID."
  (when words
    (with-mutex (*db-lock*)
      (clsql:delete-instance-records words))))

(defun add-mmy-words (user words &optional (category "general") (title "title"))
  "Add new WORDS from USER."
  (assert user () "Must have a valid user.")
  (let ((obj (make-instance 'mmy-entry
							:idx (1+ (or (caar (query "SELECT MAX(IDX) FROM mmy_entry")) 1))
							:date (parse-datestring (caar (clsql:query "select current_date")))
							:user-idx (idx user)
							:category category
							:title title
							:content words
							:verified 0)))
    (with-mutex (*db-lock*)
      (clsql:update-record-from-slots obj '(idx date user_idx category title content verified))
	  (clsql:update-instance-from-records obj))
    obj))

(defun update-mmy-words (user-id words &optional (category "general") (title "title"))
  "Add new WORDS from USER."
  (assert user-id () "Must have a valid user.")
  (let ((obj (make-instance 'mmy-entry
							:idx (1+ (or (caar (query "SELECT MAX(idx) FROM mmy_entry")) 1))
							:date (parse-datestring (caar (clsql:query "SELECT current_date")))
							:user-idx user-id
							:category category
							:title title
							:content words)))
    (with-mutex (*db-lock*)
      (clsql:update-record-from-slots obj '(idx date user_idx category title content)))
    obj))

(defun update-mmy-words-rank (words)
  "Save ranking for WORDS."
  (assert words () "Must have WORDS object.")
  (with-mutex (*db-lock*)
    (clsql:update-record-from-slots words '(up-votes down-votes))
	words))

(defun update-mmy-words-verified (words)
  "Save verified state for WORDS."
  (assert words () "Must have WORDS object.")
  (with-mutex (*db-lock*)
    (clsql:update-record-from-slots words '(verified))
	words))

(defun save-mmy-words (words)
  "Save verified state for WORDS."
  (assert words () "Must have WORDS object.")
  (with-mutex (*db-lock*)
    (clsql:update-record-from-slots words '(category title content up-votes down-votes verified))
	words))

(defun get-mmy-user (username)
  "Get a user by USERNAME."
  #+db-debug(format t "Getting user: ~A~%" username)
  (with-mutex (*db-lock*)
    (car (clsql:select 'mmy-user
					   :flatp t
					   :refresh t
					   :where
					   [= [slot-value 'mmy-user 'username] username]))))

(defun get-idx-for-mmy-user (username)
  "Get the idx (index) for USERNAME."
  (let ((user (get-mmy-user username)))
    (when user
      (idx user))))

(defun get-mmy-user-by-idx (idx)
  "Get a user by IDX."
  (assert idx (idx) "Must have a user idx.")
  (with-mutex (*db-lock*)
    (car (clsql:select 'mmy-user
					   :flatp t
					   :refresh t
					   :where
					   [= [slot-value 'mmy-user 'idx] idx]))))

(defun save-mmy-user (user)
  "Save USER to db."
  (assert user () "Must have USER object.")
  (with-mutex (*db-lock*)
    (clsql:update-record-from-slots user '(username password accuracy))))

(defun add-user-words-mapping (user-idx words-idx)
  (unless (get-user-words-mapping user-idx words-idx)
    (let ((sql (format nil "INSERT INTO mmy_map(user_idx, words_idx) VALUES(~A, ~A)" user-idx words-idx)))
      (with-mutex (*db-lock*)
        (execute-command sql)))))

(defun get-user-words-mapping (user-idx words-idx)
  (when (and user-idx words-idx)
	(let ((sql (format nil "SELECT * FROM mmy_map WHERE user_idx = ~A AND words_idx = ~A" user-idx words-idx)))
	  (with-mutex (*db-lock*)
		(query sql)))))

(defun get-user-ranked-words (user-idx)
  (when user-idx
	(let ((sql (format nil "SELECT words_idx FROM mmy_map WHERE user_idx = ~A" user-idx)))
	  (with-mutex (*db-lock*)
		(query sql :flatp t :field-names nil)))))

(clsql:locally-disable-sql-reader-syntax)
