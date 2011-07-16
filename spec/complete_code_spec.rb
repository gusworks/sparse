require 'spec_helper'

describe Sparse do
  context "Complete source code" do
    before :each do
      @parser = Sparse.new
    end

    # http://www.csc.villanova.edu/~dmatusze/resources/lisp/lisp-example.html
    it "copied from villanova" do
      code = <<lisp
; Try to apply each rule in turn to the expression.  SIMPLIFY picks
; up the rules and gives them, along with the expression, to SIMPLIFY-2.
; SIMPLIFY-2 picks off one rule and applies it by calling APPLY-RULE,
; then recurs with the remaining rules. APPLY-RULE breaks the rule up
; into pattern and replacement parts and gives these, along with the
; expression, to SUBSTITUTE.

(defun simplify (expression)
    (simplify-2 (rules) expression)  )

(defun simplify-2 (rules expression)
    (cond
    ((null rules)  expression)
    (T  (simplify-2 (cdr rules) (apply-rule (car rules) expression)))  )  )

(defun apply-rule (rule expression)
    (substitute (car rule) (cadr rule) expression)  )


; Try to match the pattern to the expression.  If it matches, replace
; the part matched with the replacement, and return the result.
; If the pattern doesn't apply, the result is the original expression.
; Example: (substitute '(1 + $) '($ + 1) '(A + 1 + B + C)) returns
;(A + B + 1 + C)

(defun substitute (pattern replacement expression)
    (cond
    ((null expression)  ())
    ((occurs-at-front pattern expression)
        (substitute-at-front pattern replacement expression) )
    (T (cons (car expression) 
             (substitute pattern replacement (cdr expression)) ))  )  )


; Test whether the pattern occurs at the very front of the expression.
; This function uses MATCHES to test individual components of the pattern.
; Example: (occurs-at-front '($ + 0) '(A + 0 + B)) returns T

(defun occurs-at-front (pattern expression)
    (cond
    ((null pattern)  T)
    ((null expression)  nil)
    ((matches (car pattern) (car expression))
        (occurs-at-front (cdr pattern) (cdr expression)) )
    (T  nil)  )  )


; Test whether the first component of the pattern matches the
; first component of the expression.  A match occurs if:
;    1. The pattern component is '$
;    2. They are identical atoms

(defun matches (pattern-part expression-part)
    (cond
    ((eq pattern-part '$)  T)
    (T  (eq pattern-part expression-part))  )  )


; This function should be called only when we know that the pattern
; matches the front of the expression.
; If the pattern contains a $, find and return the corresponding
; component (atom or list) of the expression.  If the pattern
; does not contain a $, return NIL.
; (Note: this means you can't replace $ with NIL, but for this
;  example, using arithmetic expressions, you shouldn't ever want to.)
; Example: (get-$-match '(0 + $) '(0 + A + B))  returns  A

(defun get-$-match (pattern expression)
    (cond
    ((null expression)  nil)
    ((eq (car pattern) '$)  (car expression))
    (T  (get-$-match (cdr pattern) (cdr expression)))  )  )


; In the replacement, substitute the value we found for the $ for
; the $ itself.  If $-value is NIL, that means the pattern did not
; contain a $, and the replacement shouldn't have one, either.
; Example: (substitute-in-replacement 'A '($ + 0)) returns (A + 0).

(defun substitute-in-replacement ($-value replacement)
    (cond
    ((null $-value)  replacement)
    ((null replacement)  ())
    ((eq (car replacement) '$)  (cons $-value (cdr replacement)))
    (T  (cons (car replacement)
              (substitute-in-replacement $-value (cdr replacement)) ))  )  )
    

; This function is called when we know the pattern matches the very
; first part of the expression.  If the pattern contains a $, that
; could match anything, and the thing it matches should be put in
; place of the $ the replacement.  If the pattern does not contain
; a $, then the replacement can be used as is.
; Example: (substitute-at-front '(0 * $) '(0) '(0 * A + B)) returns (0 + B).

(defun substitute-at-front (pattern replacement expression)
    (final-replace
        pattern
        (substitute-in-replacement (get-$-match pattern expression) replacement)
        expression )  )


; This function is called when (1) the pattern has been matched at the
; very front of the expression, and (2) the replacement has been suitably
; modified.  We step through and discard one component of the expression
; for every component of the pattern, then append the replacement to
; whatever is left of the expression.
; Example: (substitute-at-front '($ + 0) '($) '(A + 0 + B)) returns (A + B)

(defun final-replace (pattern replacement expression)
    (cond
    ((null pattern)  (append replacement expression))
    (T  (final-replace (cdr pattern) replacement (cdr expression)))  )  )


; Define the rules

(defun rules ()
    '( (($ + 0)  ($))
       ((0 + $)  ($))
       ((1 * $)  ($))
       ((0 * $)  (0))
       (($ * 0)  (0))
       ((1 + 1)  (2))
       (($ * 2 * 2)  (4 * $)) )  )

(+ 1 1)(+ 1.1 1)(+ -1 -1)(+ -1 -1.1)
(* 1 1)(* 1.1 1)(* -1 -1)(* -1 -1.1)
(- 1 1)(- 1.1 1)(- -1 -1)(- -1 -1.1)
(/ 1 1)(/ 1.1 1)(/ -1 -1)(/ -1 -1.1)

lisp
      p @parser.parse code
    end

    # http://www.lispworks.com/documentation/lcl50/ug/ug-22.html#HEADING22-0
    it 'copied from lispworks' do
      code = <<lisp
;; Declare the correct package for this application; 
;; for this example, use the "user" package.
(in-package "USER")

;; Define a default size for the queue.
(defconstant default-queue-size 100 "Default size of a queue")


;;; The following structure encapsulates a queue.  It contains a
;;; simple vector to hold the elements and a pair of pointers to
;;; index into the vector.  One is a "put pointer" that indicates
;;; where the next element is stored into the queue.  The other is
;;; a "get pointer" that indicates the place from which the next
;;; element is retrieved.
;;;
;;; When put-ptr = get-ptr, the queue is empty.
;;; When put-ptr + 1 = get-ptr, the queue is full.
(defstruct (queue (:constructor create-queue)
                  (:print-function queue-print-function))
  (elements #() :type simple-vector)    
                                 ; simple vector of elements
  (put-ptr 0 :type fixnum)       ; next place to put an element
  (get-ptr 0 :type fixnum)       ; next place to take an element
  )


;; To make QUEUE-NEXT efficient, give the Compiler some hints.
(eval-when (compile eval)
  (proclaim '(inline queue-next))
  (proclaim '(function queue-next (queue fixnum) fixnum))
  )


(defun queue-next (queue ptr)
  "Increment a queue pointer by 1 and wrap around if needed."
  (let ((length (length (queue-elements queue)))
        (try (the fixnum (1+ ptr))))
    (if (= try length) 0 try)))


(defun queue-get (queue &optional (default nil))
  ; return DEFAULT if the queue is empty."
  "Get an element from QUEUE
  (check-type queue queue)
  (let ((get (queue-get-ptr queue))
        (put (queue-put-ptr queue)))
    (if (= get put)
        ;; Queue is empty.
        default
        ;; Get the element and update the get-ptr.
        (prog1
          (svref (queue-elements queue) get)
          (setf (queue-get-ptr queue) (queue-next queue get))))))


;; Define a function to put an element into the queue.  If the
;; queue is already full, QUEUE-PUT returns NIL.  If the queue
;; isn't full, QUEUE-PUT stores the element and returns T.
(defun queue-put (queue element)
  "Store ELEMENT in the QUEUE and return T on success or NIL on failure."
  (check-type queue queue)
  (let* ((get (queue-get-ptr queue))
         (put (queue-put-ptr queue))
         (next (queue-next queue put)))
    (unless (= get next)
      ;; store element
      (setf (svref (queue-elements queue) put) element) 
      (setf (queue-put-ptr queue) next)      ; update put-ptr
      t)))                                   ; indicate success


;; Define a SETF method.
(defsetf queue-get queue-put)


(defun queue-print-function (queue stream depth)
  "This is the function used to print queue structures."
  (declare (ignore depth))
  (multiple-value-bind (current-size max-size)
      (queue-length queue)
    (format stream "#<Queue ~A/~A ~X>" 
            current-size
            max-size
            (liquid::%pointer queue))))


(defun queue-length (queue)
  "Returns as two values the number of elements in the queue 
   and the maximum number of elements the queue can hold."
  (check-type queue queue)
  (let ((length (length (queue-elements queue)))
        (delta (the fixnum (- (queue-put-ptr queue) 
          (queue-get-ptr queue)))))
    (declare (fixnum length delta))
    ;; The maximum number of elements the queue can hold is 
    ;; (1- LENGTH) because a queue is empty when put-ptr = 
    ;; get-ptr.
    (values (mod delta length) (the fixnum (1- length)))))


(defun queue-empty-p (queue)
  "Return T if QUEUE is empty."
  (check-type queue queue)
  (= (queue-put-ptr queue) (queue-get-ptr queue)))


(defun queue-full-p (queue)
  "Return T if QUEUE is full."
  (check-type queue queue)
  (= (queue-get-ptr queue) 
     (queue-next queue (queue-put-ptr queue))))


;; Create a queue. The :ELEMENTS keyword specifies a simple
;; vector to hold the elements of the queue. Note that the
;; maximum number of elements the queue can hold is one less than
;; the length of the vector.
(defun make-queue (&key (elements (make-array (1+ default-queue-size))))
  "Create a queue."
  (check-type elements simple-vector)
  (create-queue :elements elements))
lisp
      p @parser.parse code
    end
end
