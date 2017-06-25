;;;; Database persistence classes.

(in-package :com.markmywords.db)

;;(declaim (optimize debug))

(clsql:def-view-class mmy-user ()
  ((idx
    :db-kind :key
    :db-constraints :not-null
    :accessor idx
    :type integer
    :initarg :idx)
   (username
    :accessor username
    :type varchar
    :initarg :username)
   (password
    :accessor password
    :type varchar
    :initarg :password)
   (admin
    :accessor adminp
    :type integer
    :initarg :admin
	:initform 0)
   (accuracy
    :accessor accuracy
    :type float
    :initarg :accuracy
	:initform 0.0)))

(clsql:def-view-class mmy-words ()
  ((idx
    :db-kind :key
    :db-constraints :not-null
    :accessor idx
    :type integer
    :initarg :idx)
   (user_idx
    :accessor user-idx
    :type integer
    :initarg :user-idx)
   (user
    :accessor user
    :db-kind :join
    :db-info (:join-class mmy-user
			  :home-key user_idx
			  :foreign-key idx
			  :set nil))
   (date
    :accessor date
    :type date
    :initarg :date)
   (category
    :accessor category
    :type (varchar 40)
    :initarg :category)
   (title
    :accessor title
    :type (varchar 40)
    :initarg :title)
   (content
    :accessor content
    :type (varchar 2000)
    :initarg :content)
   (up-votes
    :accessor up-votes
    :type integer)
   (down-votes
    :accessor dn-votes
    :type integer)
   (verified
    :accessor verified
    :type integer
    :initarg :verified
	:initform 0)))

(clsql:def-view-class mmy-map ()
  ((idx
    :db-kind :key
    :db-constraints :not-null
    :accessor idx
    :type integer
    :initarg :idx)
   (user_idx
    :accessor user-idx
    :type integer
    :initarg :user-idx)
   (user
    :accessor user
    :db-kind :join
    :db-info (:join-class mmy-user
			  :home-key user_idx
			  :foreign-key idx
			  :set nil))
   (words_idx
    :accessor words-idx
    :type integer
    :initarg :words-idx)
   (words
    :accessor words
    :db-kind :join
    :db-info (:join-class mmy-words
			  :home-key words_idx
			  :foreign-key idx
			  :set nil))))
