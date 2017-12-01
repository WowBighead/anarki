(def spliceable-list (n (o init))
"Create a spliceable list with a constant suffix length of n. A spliceable
list is a special data structure that efficiently supports the following
operations:

1. Destructively appending items using [[nappend]].
2. Returning the last n items appended using [[suffix]] if there are at least
n items to return.
3. Dropping the last n items appended, and returning everything else. [[splice]]"
  ++.n
  (annotate 'spliceable-list (obj contents init
                                  last lastcons.init
                                  suffix-len n
                                  pre-suffix (suffix n init))))

(defextend len (l) (isa l 'spliceable-list)
  (len rep.l!contents))

(defextend empty (l) (isa l 'spliceable-list)
  (empty rep.l!contents))

(defextend nappend (l item) (isa l 'spliceable-list)
  (if empty.l
    (= rep.l!contents list.item
       rep.l!last rep.l!contents)
    (= (cdr rep.l!last) list.item))
  (zap lastcons rep.l!last)
  (if rep.l!pre-suffix
    (zap cdr rep.l!pre-suffix)
    ; no pre-suffix yet; do we have enough elems to start?
    (if (is rep.l!suffix-len (len rep.l!contents))
      (= rep.l!pre-suffix rep.l!contents))))

; like njoin, but instead of entire list, returns just the pre-suffix
(def nslide (l tail)
  (each x tail
    (nappend l x))
  rep.l!pre-suffix)

(defcoerce cons spliceable-list (l)
  rep.l!contents)

(defcoerce spliceable-list cons (l)
  (spliceable-list l))

(defcall spliceable-list (l i)
  rep.l!contents.i)

(defextend sref (l v i) (isa l 'spliceable-list)
  (sref rep.l!contents v i))

(def splice (l)
"Clears up to the last n items of a [[spliceable-list]] defined with a suffix
length of n, and returns everything else."
  (when rep.l!pre-suffix
    (wipe (cdr rep.l!pre-suffix))
    rep.l!contents))

(examples splice
  (splice (spliceable-list 3))
  nil
  (splice (spliceable-list 3 '(1)))
  nil
  (splice (spliceable-list 3 '(1 2)))
  nil
  (splice (spliceable-list 3 '(1 2 3)))
  nil
  (splice (spliceable-list 3 '(1 2 3 4)))
  (1))

(def suffix (n l)
"Computes the last n elements of l -- as long as there are at least that many."
  (let max len.l
    (if (>= max n)
      (nthcdr (- max n) l))))

(examples suffix
  (suffix 3 '(1))
  nil
  (suffix 3 '(1 2))
  nil
  (suffix 3 '(1 2 3))
  (1 2 3)
  (suffix 3 '(1 2 3 4))
  (2 3 4))

(defextend suffix (l) (isa l 'spliceable-list)
  (aif
    rep.l!pre-suffix
      cdr.it
    (iso (len rep.l!contents) (- rep.l!suffix-len 1))
      rep.l!contents))
