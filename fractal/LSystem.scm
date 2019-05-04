#lang racket
(require racket/gui)
(require racket/draw)
(require mrlib/path-dialog)

(define stack (list))
(define (push stack element)
  (set! stack (cons element stack)))
(define (pop stack)
  (let ((element (car stack)))
    (set! stack (cdr stack))
    element))

(define rules
  '((F  . "F[-F]F[+F]F")))

(define parameters
  '((axiom      . "F" )
    (angle      . 60  )
    (lineLength . 4   )
    (iteration  . 4   )))


(define (open menu-item event)
  (define open-file-dialog
    (new path-dialog% 
         [existing? #t]))
  (send open-file-dialog show #t))

(define (draw menu-item event)
  (open menu-item event)
  (draw-fractal (send canvas get-dc) ""))

(define draw-fractal
  (lambda (dc actions)
    (if (null? actions) '()
        (begin
          (perform (car actions))
          (draw-fractal dc (cdr actions))))))

(define (perform action)
  (cond
    ((eq? action #\F) ())
    ((eq? action #\+) ())
    ((eq? action #\-) ())
    ((eq? action #\[) ())
    ((eq? action #\]) ())))


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
