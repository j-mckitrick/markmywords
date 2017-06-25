(in-package #:cl-user)

;;(push :server-debug *features*)

(defpackage #:com.markmywords.serve
  (:nicknames #:serve)
  (:documentation "Hunchentoot functionality for mark my words web app.")
  (:use #:cl #:cl-user #:hunchentoot #:xml-emitter #:split-sequence #:html-template #:json #:cl-ppcre
	#:com.markmywords.db #:com.markmywords.app)
  (:export
   #:mmy-web-start
   #:mmy-web-stop

   ;; functions
   #:verify-user-and-password
   
   ;; variables
   #:*users*

   ;; constants
   #:+server-port+
   
   #:+url-login+
   #:+url-logout+
   ))
