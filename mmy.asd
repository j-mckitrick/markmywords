;; Copyright © 2007 Jonathon McKitrick.  All Rights Reserved.

(defpackage #:mmy-system (:use #:cl #:asdf))
(in-package #:mmy-system)

(defsystem mmy
  :name "markmywords"
  :version "1.0"
  :author "Jonathon McKitrick"
  :description "Mark My Words web app"
  :components
  ((:file "start" :depends-on ("com.markmywords.serve"))
   (:module "com.markmywords.serve" :depends-on ("com.markmywords.app") :serial t
	    :components ((:file "defpackage")
					 (:file "macros")
					 (:file "util")
					 (:file "mmy-conf")
					 (:file "mmy-auth")
					 (:file "mmy-handlers")))
   (:module "com.markmywords.app" :depends-on ("com.markmywords.db") :serial t
	    :components ((:file "defpackage")
					 (:file "entries")))
   (:module "com.markmywords.db" :serial t
			:components ((:file "defpackage")
						 (:file "db-classes")
						 (:file "db-sql"))))
  :depends-on (:hunchentoot :net-telent-date :split-sequence :html-template :cl-who
							:clsql :cl-json :rfc2388 :xml-emitter))

