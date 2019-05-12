#lang racket

(provide (all-defined-out))

(require picturing-programs)


(require "common.scm")

(define (remainder* n1 n2)
  (define num-divides (/ n1 n2))
  (- n1 (* (floor num-divides) n2)))

(define (make-color/hsv hue saturation value)
  (define chroma (* saturation value))
  (define hue* (/ (remainder* hue (* 2 pi)) (/ pi 3)))
  (define X (* chroma (- 1 (abs (- (remainder* hue* 2) 1)))))
  (define-values (r1 g1 b1)
    (cond [(and (<= 0 hue*) (< hue* 1)) (values chroma X 0)]
          [(and (<= 1 hue*) (< hue* 2)) (values X chroma 0)]
          [(and (<= 2 hue*) (< hue* 3)) (values 0 chroma X)]
          [(and (<= 3 hue*) (< hue* 4)) (values 0 X chroma)]
          [(and (<= 4 hue*) (< hue* 5)) (values X 0 chroma)]
          [(and (<= 5 hue*) (< hue* 6)) (values chroma 0 X)]))
  (define m (- value chroma))
  (apply make-color (map (lambda (x) (exact-round (* 255 (+ x m))))
                         (list r1 g1 b1))))

(define (draw-julia canvas config)
  (define *width*  640)
  (define *height* 480)
  (define *iteration* 80)
  ;(define c (make-rectangular )) ;-0.7269 + 0.1889i
  (define c -0.4+0.6i)
  (define *background* (rectangle *width* *height* 'solid 'grey))

  (define canvas-dc (send canvas get-dc))

  (define (scaled-x x) (/ (* 1.5 (- x (/ *width* 2))) (* 0.5 *width*)))
  (define (scaled-y y) (/ (- y (/ *height* 2)) (* 0.5 *height*)))
  (define (iterate z iteration)
    (if (and (< (magnitude z) 2) (<= iteration *iteration*))
        (iterate (+ (* z z) c) (+ iteration 1))
        iteration))

  (define julia-image
    (map-image
     (lambda (x y c)
       (let* ([ref (iterate (make-rectangular (scaled-x x) (scaled-y y)) 0)])
         (cond [(= ref *iteration*) (name->color 'black)]
               [else (make-color/hsv (* 2 (* pi (/ ref *iteration*))) 1 1)]) ))
     *background*))


  (send canvas-dc draw-bitmap (send julia-image get-bitmap) 0 0)
)