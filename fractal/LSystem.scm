#lang racket

(provide (all-defined-out))

(require racket/draw)
(require "common.scm")

(define (draw-by-LSystem canvas config)
  (define *axiom* '())
  (define *angle* '())
  (define *line-length* '())
  (define *iteration* '())
  (define *start-x* '())
  (define *start-y* '())
  (define *start-angle* '())
  (define *rules* '())
  (define (load-config config)
    (set! *axiom* (get-assoc-value config 'axiom))
    (set! *angle* (get-assoc-value config 'angle))
    (set! *line-length* (get-assoc-value config 'line-length))
    (set! *iteration* (get-assoc-value config 'iteration))
    (set! *start-x* (get-assoc-value config 'start-x))
    (set! *start-y* (get-assoc-value config 'start-y))
    (set! *start-angle* (get-assoc-value config 'start-angle))
    (set! *rules* (get-assoc-value config 'rules)))

  (define stack (make-stack))
  (define current-state '())
  (define point '())

  (define (next-point p angle)
    (cons (+ (car p) (* *line-length* (sin (degrees->radians angle))))
          (+ (cdr p) (* *line-length* (cos (degrees->radians angle))))))
  (define (expand-once actions-string)
    (string-append* (map (lambda (s)
                           (define rule (get-assoc-value *rules* s))
                           (if (not rule) (list->string (list s))
                               rule))
                         (string->list actions-string))))

  (define (expand actions-string iteration)
    (if (<= iteration 0) actions-string
        (expand (expand-once actions-string) (- iteration 1))))
  (define (generate-actions)
    (expand *axiom* *iteration*))
  (define (perform-draw dc action)
    (cond
      ((char-upper-case? action)
       (set! point (next-point (car current-state) (cdr current-state)))
       (send dc draw-lines (list (car current-state) point))
       (set! current-state (cons point (cdr current-state))))
      ((eq? action #\+)
       (set! current-state (cons (car current-state) (+ (cdr current-state) *angle*))))
      ((eq? action #\-)
       (set! current-state (cons (car current-state) (- (cdr current-state) *angle*))))
      ((eq? action #\[)
       (push! stack current-state))
      ((eq? action #\])
       (if (stack-empty? stack) '()
           (set! current-state (pop! stack))))))
  (define (draw-fractal dc actions)
    (if (null? actions) '()
        (begin
          (perform-draw dc (car actions))
          (draw-fractal dc (cdr actions)))))

  (load-config config)
  (set! current-state (cons (cons *start-x* *start-y*) *start-angle*))
  (draw-fractal (send canvas get-dc) (string->list (generate-actions))))
