
; make-system-resource
(define (make-system-resource id type address block-size blocks)
	(define-message *copy* "M-copy"@00)
	(lambda (message)
		(case message
			((*copy*)
				(lambda ()
					()))
			(else ()))))
;

(define (make-process pid state killed resources parent-process)
	(lambda (message)
		(case message
			((*fork*)
				(lambda ()
					()))
			(else ()))))
;

(define-generic move-resource)
(define-method (move-resource (s "Register"@00) (t "Register"@00)) (...))

