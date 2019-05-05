#lang racket
(require racket/gui)
(require racket/draw)
(require racket/file)
(require mrlib/path-dialog)

(define stack (list))
(define (push stack element)
  (set! stack (cons element stack)))
(define (pop stack)
  (let ((element (car stack)))
    (set! stack (cdr stack))
    element))

;(define rules
;  '(("F"  . "F[-F]F[+F]F")))
;
;(define parameters
;  '((axiom      . "F" )
;    (angle      . 60  )
;    (lineLength . 4   )
;    (iteration  . 4   )
;    (startX     . 100 )
;    (startY     . 100 )))


(define x 100)
(define y 100)
(define angle 0)

(define (get-assoc-value alist key)
  (define p (assoc key alist))
  (if (pair? p)
      (cdr p)
      p))

(define (expand-once actions-string rules)
  (string-append* (map (lambda (s)
                         (display s)
                         (define rule (get-assoc-value rules s))
                         (if (null? rule) (list->string (list s))
                             rule))
                       (string->list actions-string))))

(define (expand actions-string rules iteration)
  (if (<= iteration 0) actions-string
      (expand (expand-once actions-string rules) rules (- iteration 1))))

(define (generate-actions file-path)
  (define config-string (file->string file-path))
  (define config (eval (read (open-input-string config-string))))
  (cons config
        (expand (get-assoc-value config 'axiom)
                (get-assoc-value config 'rules)
                (get-assoc-value config 'iteration))))

(define (draw menu-item event)
  (define file-path (get-file "open fractal config file" main-frame))
  (define config (generate-actions file-path))
  (if file-path
      (draw-fractal (send canvas get-dc) (cdr config) (car config))
      '()))

(define draw-fractal
  (lambda (dc actions config)
    (if (null? actions) '()
        (begin
          (perform dc (car actions) config)
          (draw-fractal dc (cdr actions) config)))))

(define (perform dc action config)
  (define lineLength (get-assoc-value config 'lineLength))
  (define theAngle (get-assoc-value config 'angle))
  (cond
    ((eq? action #\F)
     (send dc draw-lines
           (list (cons x y)
                 (cons (+ x (* lineLength (sin (degrees->radians angle))))
                       (+ y (* lineLength (cos (degrees->radians angle)))))))
     (set! x (+ x (* lineLength (sin (degrees->radians angle)))))
     (set! y (+ y (* lineLength (cos (degrees->radians angle))))))
    ((eq? action #\+)
     (set! angle (+ angle theAngle)))
    ((eq? action #\-)
     (set! angle (- angle theAngle))))
    ((eq? action #\[)
     (push stack x)
     (push stack y)
     (push stack angle))
    ((eq? action #\])
     (set! angle (pop stack))
     (set! y (pop stack))
     (set! x (pop stack))))


(define main-frame
  (new frame%
       [label "分形"]
       [width 800]
       [height 600]
       [border 5]))

(define panel-canvas
  (new vertical-panel%
       [parent main-frame]
       [style '(border)]
       [alignment '(left top)]
       [border 10]))

(define canvas
  (new canvas%
       [parent panel-canvas]))

(define menubar
  (new menu-bar%
       [parent main-frame]))

(define menu-file
  (new menu%
       [label "文件"]
       [parent menubar]))
(define menu-item-open
  (new menu-item%
       [label "打开"]
       [parent menu-file]
       [callback draw]))
(define menu-item-exit
  (new menu-item%
       [label "退出"]
       [parent menu-file]
       [callback
        (lambda (item event)
          (send main-frame on-exit))]))

(send main-frame show #t)
