(in-package #:com.markmywords.serve)

(defparameter *mmy-server* nil)
(defparameter +server-port+ 8000)

(defparameter *app-log-enable* t)

(defparameter *app-prefix* "mmy")

(setf html-template:*warn-on-creation* nil)

(setf *log-lisp-errors-p* t)
;;(setf *lisp-errors-log-level* :info)

(setf *log-lisp-warnings-p* t)
;;(setf *lisp-warnings-log-level* :info)

;;(setf *break-on-signals* t)
(setf *catch-errors-p* nil)
(setf *show-lisp-errors-p* t)
;;(setf *show-lisp-backtraces-p* t)
;;(setf *show-access-log-messages* nil)
