(in-package #:cl-user)

;(push :db-debug *features*)

(defpackage #:com.markmywords.db
  (:nicknames #:db)
  (:documentation "Database interface functions.")
  (:use #:cl #:cl-user #:clsql #:sb-thread #:split-sequence)
  (:export

   ;; classes
   #:mmy-user
   #:mmy-entry
   
   ;; accessors
   #:idx
   #:username
   #:password
   #:date
   #:user
   #:category
   #:title
   #:content
   #:up-votes
   #:dn-votes
   #:adminp
   #:accuracy
   #:verified
   
   ;; methods

   ;; functions
   #:connect-to-mmy
   #:disconnect-from-mmy

   #:get-mmy-user
   #:get-mmy-user-by-idx
   #:get-idx-for-mmy-user
   #:get-mmy-users
   #:save-mmy-user
   #:get-mmy-words
   #:get-mmy-words-for-user
   #:get-verified-mmy-words-for-user
   #:search-mmy-words
   #:get-one-mmy-words
   #:get-popular-mmy-words
   #:get-popular-mmy-words-n
   #:add-mmy-words
   #:delete-mmy-words
   #:update-mmy-words-rank
   #:add-user-words-mapping
   #:save-mmy-words
   
   ;; variables
   ))
