(in-package #:cl-user)

(defun ignore-simple-error (c)
  (invoke-restart 'com.markmywords.serve::ignore-simple-error c))

(defun ignore-unbound-slot (c)
  (invoke-restart 'com.markmywords.serve::ignore-unbound-slot c))

(defun ignore-shutdown-condition (c)
  (invoke-restart 'com.markmywords.serve::ignore-shutdown-condition c))

(defun mmy-stop ()
  "Stop mmy application (db and web server)."
  (handler-case (com.markmywords.db:disconnect-from-mmy)
    (simple-error (e) (format t "DISCONNECT error ignored: ~A~%" e)))
  (handler-bind ((simple-error #'ignore-simple-error)
				 (unbound-slot #'ignore-unbound-slot)
				 (simple-error #'ignore-shutdown-condition))
    (com.markmywords.serve:mmy-web-stop)))

(defun mmy-start ()
  "Main system startup."
  (when serve::*mmy-server*
    (mmy-stop))
  (com.markmywords.db:connect-to-mmy)
  (sb-thread:make-thread 'com.markmywords.serve:mmy-web-start))

(mmy-start)
