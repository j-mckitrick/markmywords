(in-package #:com.markmywords.serve)

;;(declaim (optimize debug))
(declaim (optimize speed))

(defmacro with-pattern-tokens ((pattern tokens) &body body)
  "Bind the regs from PATTERN matches to TOKENS for BODY."
  `(multiple-value-bind (whole-match regs)
       (scan-to-strings ,pattern (script-name*))
     (when whole-match
       (destructuring-bind (&optional ,@tokens) (coerce regs 'list)
		 ,@body))))

(defmacro wrap-as-xml-result (&body body)
  "Wrap all output from BODY as an xml document."
  `(with-output-to-string (*standard-output*)
     (with-xml-output (*standard-output*)
       ,@body)))

(defmacro with-html-output ((stream) &body body)
  "Wrap XML output on STREAM with the necessary XML heading information"
  `(let ((xml-emitter::*xml-output-stream* ,stream))
	 ,@body))

(defmacro wrap-as-html-result (&body body)
  "Wrap all output from BODY as an xml document."
  `(with-output-to-string (*standard-output*)
     (with-html-output (*standard-output*)
       ,@body)))

(defmacro with-html (&body body)
  "Output to html."
  `(cl-who:with-html-output-to-string (*standard-output* nil :prologue nil)
     ,@body))

#+nil
(defmacro object->json (report-class report-object)
  (let* ((class (find-class report-class))
         (slots (mapcar #'sb-mop:slot-definition-name (sb-mop:class-slots class)))
         (object (gensym)))
    `(let ((,object ,report-object))
       (list
        ,@(mapcar
           (lambda (slot)
             `(cons ,(intern (symbol-name slot) :keyword)
                    ,(ecase (type-of (slot object))
                            (float
                             `(format nil "~,2F" (slot-value ,object ',slot))))
                    ))
           slots)))))

#+nil
(object->json mmy-entry (first (get-entries)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun mkstr (&rest args)
    (with-output-to-string (s)
      (dolist (a args) (princ a s))))

  (defun symb (&rest args)
    (values (intern (apply #'mkstr args))))

  (defun extract-params (params)
    (loop
	   for param in params
	   when (listp param) collect (car param)
	   else collect param)))

(defmacro define-resource-type (type verbs methods &key with-id)
  `(defmacro ,(symb 'define-resource- type) (resource-name functions &optional args)
     (let ((regex (format nil "^/~A~A$" resource-name ,(if with-id "/(\\d+)" ".*")))
		   (handlers (mapcar (lambda (verb)
							   (symb (string-upcase (format nil "handle-~A-" verb))
									 (string-upcase resource-name)))
							 ',verbs)))
       `(progn
		  ,@(mapcar (lambda (h m f)
					  `(define-easy-handler
						   (,h :uri (lambda (r) (rest-url-p r ,m ,regex))) ,args
						 ,,(if with-id
							   ``(with-pattern-tokens (,regex (,',with-id))
								   (funcall #',f ,',with-id ,@(extract-params args)))
							   ``(funcall #',f ,@(extract-params args)))))
					handlers ',methods
					,(if (and (> (length verbs) 1) (> (length methods) 1)) `functions `(list functions)))))))

(macrolet ((define-resource-type-lambda (type verb method)
			 `(define-resource-type ,type ,(list verb) ,(list method))))
  ;; html
  (define-resource-type-lambda html "get-html" "GET")
  ;; ???
  (define-resource-type-lambda query "get-query" "GET")
  ;; json
  (define-resource-type-lambda gettable-json "get" "GET")
  (define-resource-type-lambda settable-json "set" "POST")
  (define-resource-type-lambda procedure-json "procedure" "POST"))

(define-resource-type get-one-json ("get-one") ("GET") :with-id id)
(define-resource-type puttable-json ("put") ("PUT") :with-id id)
(define-resource-type deletable-json ("delete") ("DELETE") :with-id id)
