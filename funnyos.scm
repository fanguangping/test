
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


(define (make-JobQueue self priority quantum the-time??)
	(lambda (message)
		(case message
			((*fork*)
				(lambda ()
					()))
			(else ()))))

(define (make-Job id processes arrive-time turnaround-time wait-time response-time last-ran finished) 
	(lambda (message)
		(case message
			((*init-stat*)
				(lambda ()
					(begin (set! turnaround-time 0)
						(set! wait-time 0)
						(set! response-time -1))))
			((*set-response-time*)
				(lambda (the-time)
					(if (eqv response-time -1) (set! response-time the-time))))
			((*calc-wait-time*)
				(lambda (the-time)
					(set! wait-time (+ wait-time (- the-time last-ran)))))
			(else ()))))

(define (make-MultiLevelFeedbackQueue )
	())

(define round-robin (lambda (job-queue)
	(if (is-not-empty? job-queue) 
		(let* ((job (dequeue job-queue)) ()) 
			(ask job *set-response-time*)
			(ask job *calc-wait-time*)
			()))))

;

; https://github.com/shreyakamath2311/Xv6-MLFQ-Scheduler/tree/master/xv6/kernel



(define *paren-left*     "(")
(define *paren-right*    ")")
(define *bracket-left*   "[")
(define *bracket-right*  "]")
(define *brace-left*     "{")
(define *brace-right*    "}")

(define *nil-macro*   "nil")
(define *M-SystemMacro-eval*  1)

(define (MAKE-SystemMacro self name function mapping-string run-string eval-string)
  (define (nil-macro? string) (eq? string *nil-macro*))
  (lambda (message)
    (case message
      ((*M-SystemMacro-eval*)
       (lambda ()
         (cond ((nil-macro? mapping-string) (+ 1 2))
               ((nil-macro? run-string) (+ 1 2))
               ((nil-macro? eval-string) (+ 1 2))
               (else (+ 1 2)))))
      (else (+ 1 2)))))

(define (parse-macro macro-string replacements)
  ())
;








