(in-package #:cl-user)

(defpackage #:com.markmywords.app
  (:nicknames #:app)
  (:documentation "App functions for Mark My Words.")
  (:use #:cl #:cl-user #:com.markmywords.db)
  (:export

   ;; functions
   #:get-entries
   #:add-entry
   #:upvote-entry
   #:dnvote-entry
   #:delete-entry
   #:get-user-profile
   #:add-user-profile
   #:update-user-profile
   #:get-users

   #:get-popular-entries
   #:get-most-popular-entry
   #:rank-entry
   
   ;; variables
   #:my-user

   #:up
   #:dn
   ))