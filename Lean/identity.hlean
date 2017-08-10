/-------------------------------------------------------------------------------
  LECTURE 3. Identity types

-------------------------------------------------------------------------------/

prelude

import .inductive_types

/--
From the perspective of types as proof-relevant propositions, how should we 
think of \emph{equality} in type theory? Given a type $A$, and two terms 
$x,y:A$, the equality $\id{x}{y}$ should again be a type. Indeed, we want to 
\emph{use} type theory to prove equalities. \emph{Dependent} type theory 
provides us with a convenient setting for this: the equality type $\id{x}{y}$ 
is dependent on $x,y:A$. 

Then, if $\id{x}{y}$ is to be a type, how should we think of the terms of 
$\id{x}{y}$. A term $p:\id{x}{y}$ witnesses that $x$ and $y$ are equal terms of 
type $A$. In other words $p:\id{x}{y}$ is an \emph{identification} of $x$ and 
$y$. In a proof-relevant world, there might be many terms of type $\id{x}{y}$. 
I.e.~there might be many identifications of $x$ and $y$. And, since $\id{x}{y}$ 
is itself a type, we can form the type $\id{p}{q}$ for any two identifications 
$p,q:\id{x}{y}$. That is, since $\id{x}{y}$ is a type, we may also use the type 
theory to prove things \emph{about} identifications (for instance, that two 
given such identifications can themselves be identified), and we may use the 
type theory to perform constructions with them. As we will see shortly, we can 
give every type a groupoid-like structure.

Clearly, the equality type should not just be any type dependent on $x,y:A$. 
Then how do we form the equality type, and what ways are there to use 
identifications in constructions in type theory? The answer to both these 
questions is that we will form the identity type as an \emph{inductive} type, 
generated by just a reflexivity term providing an identification of $x$ to 
itself. The induction principle then provides us with a way of performing 
constructions with identifications, such as concatenating them, inverting them, 
and so on. Thus, the identity type is equipped with a reflexivity term, and 
further possesses the structure that are generated by its induction principle 
and by the type theory. This inductive construction of the identity type is 
elegant, beautifully simple, but far from trivial!

The situation where two terms can be identified in possibly more than one way 
is analogous to the situation in \emph{homotopy theory}, where two points of a 
space can be connected by possibly more than one \emph{path}. Indeed, for any 
two points $x,y$ in a space, there is a \emph{space of paths} from $x$ to $y$. 
Moreover, between any two paths from $x$ to $y$ there is a space of 
\emph{homotopies} between them, and so on. This analogy has been made precise 
by the construction of \emph{homotopical models} of type theory, and it has led 
to the fruitful research area of \emph{synthetic homotopy theory}, the subfield 
of \emph{homotopy type theory} that is the topic of this course.
--/

inductive Id.{l} {A : Type.{l}} (x : A) : A → Type.{l} :=
  refl : Id x x

print Id.refl
print Id.rec
print Id.rec_on

namespace Id

/--
In the following few definitions we establish that any type possesses a 
groupoid-like structure. More precisely, we construct inverses and 
concatenations of paths, and show that the associativity, inverse, and unit 
laws are satisfied.
--/

definition inv {A : Type} {x y : A} (p : Id x y) : Id y x :=
  Id.rec (refl x) p

definition concat {A : Type} {x y : A} (p : Id x y) {z : A} (q : Id y z) 
  : (Id x z) :=
  Id.rec p q

definition assoc {A : Type} {x1 x2 : A} (p : Id x1 x2) {x3 : A} (q : Id x2 x3) 
  {x4 : A} (r : Id x3 x4) 
  : Id (concat (concat p q) r) (concat p (concat q r)) :=
  Id.rec (Id.rec (Id.rec (refl _) p) q) r

definition left_inv {A : Type} {x y : A} (p : Id x y) 
  : Id (concat (inv p) p) (Id.refl y) :=
  Id.rec (refl (refl x)) p 

definition right_inv {A : Type} {x y : A} (p : Id x y) 
  : Id (concat p (inv p)) (Id.refl x) :=
  Id.rec (refl (refl x)) p

definition left_unit {A : Type} {x y : A} (p : Id x y) 
  : Id (concat (refl x) p) p :=
  Id.rec (refl (refl x)) p

definition right_unit {A : Type} {x y : A} (p : Id x y) 
  : Id (concat p (Id.refl y)) p :=
  Id.rec (refl (refl x)) p

/--
Apart from the groupoid operations and laws, the whiskering and unwhiskering
operations are also basic operations of importance. We will need the whiskering
operations, for instance, to establish that the action on paths of a function
respects the groupoid-like structure of types that we established above. The
unwhiskering operations are inverse to the whiskering operations.
--/

definition whisker_left {A : Type} {x y : A} (p : Id x y) {z : A} 
  {q r : Id y z} (u : Id q r) 
  : Id (concat p q) (concat p r) :=
  Id.rec (refl (concat p q)) u

definition whisker_right {A : Type} {x y : A} {p q : Id x y} (u : Id p q) 
  {z : A} (r : Id y z) 
  : Id (concat p r) (concat q r) :=
  Id.rec u r

definition unwhisker_left {A : Type} {x y : A} (p : Id x y) 
  : forall {z : A} {q r : Id y z} (u : Id (concat p q) (concat p r)), Id q r 
  :=
  Id.rec (λ z q r u, concat (inv (left_unit q)) (concat u (left_unit r))) p

definition unwhisker_right {A : Type} {x y : A} {p q : Id x y} {z : A} 
  (r : Id y z) 
  : forall (u : Id (concat p r) (concat q r)), Id p q :=
  Id.rec (λ u, concat (inv (right_unit p)) (concat u (right_unit q))) r

definition inv_con {A : Type} {x y z : A} (p : Id x y) 
  : Π (q : Id y z) (r : Id x z), Id (Id.concat p q) r 
  → Id q (Id.concat (Id.inv p) r) :=
  Id.rec (Id.rec (λ r, Id.rec (Id.refl _))) p

definition con_inv {A : Type} {x y z : A} (p : Id x y) (q : Id y z) 
  (r : Id x z)
  : Id (Id.concat p q) r → Id p (Id.concat r (Id.inv q)) :=
  Id.rec (Id.rec (Id.refl _) q)

definition inv_con' {A : Type} {x y z : A} {p : Id x y} 
  {q : Id y z} {r : Id x z}
  (s : Id r (concat p q)) : Id (concat (inv p) r) q :=
  inv (inv_con p q r (inv s))

definition con_inv' {A : Type} {x y z : A} {p : Id x y} {q : Id y z}
  {r : Id x z} (s : Id r (concat p q)) 
  : Id (concat r (inv q)) p
  :=
  inv (con_inv p q r (inv s))

end Id

/--
Action on paths
--/

definition ap {A B : Type} (f : A → B) {x y : A} (p : Id x y) 
  : Id (f x) (f y) :=
  Id.rec (Id.refl (f x)) p

namespace ap

/-- 
Before we show that ap f preserves the groupoid structure, we show that ap (idfun A) is (pointwise equal to) the identity funcion on Id x y.
--/

definition idfun {A : Type} {x y : A} (p : Id x y) : Id (ap (λ a, a) p) p :=
  Id.rec (Id.refl _) p

definition compose {A B C : Type} (f : A → B) (g : B → C) {x y : A} 
  (p : Id x y)
  : Id (ap (λ x, g (f (x))) p) (ap g (ap f p))
  :=
  Id.rec (Id.refl _) p

definition concat {A B : Type} (f : A → B) {x y : A} (p : Id x y) {z : A} 
  (q : Id y z) 
  : Id (ap f (Id.concat p q)) (Id.concat (ap f p) (ap f q)) :=
  Id.rec (Id.rec (Id.refl (Id.refl (f x))) p) q

definition inv {A B : Type} (f : A → B) {x y : A} (p : Id x y) 
  : Id (ap f (Id.inv p)) (Id.inv (ap f p)) :=
  Id.rec (Id.refl (Id.refl (f x))) p 

/--
The following construction shows that [ap f] respects associativity, in the 
sense that the diagram

  ap f ((p⬝q)⬝r) === (ap f (p⬝q))⬝(ap f r) === ((ap f p)⬝(ap f q))⬝(ap f r)
     ||                                                           ||
     || ap f (assoc p q r)       assoc (ap f p) (ap f q) (ap f r) ||
     ||                                                           ||
  ap f (p⬝(q⬝r)) === (ap f p)⬝(ap f (q⬝r)) === (ap f p)⬝((ap f q)⬝(ap f r))

commutes. Unsurprisingly, the structure of the proof is exactly the same as 
that for the proof of associativity of path concatenation.
--/

definition assoc {A B : Type} (f : A → B) {x1 x2 : A} (p : Id x1 x2) {x3 : A} 
  (q : Id x2 x3) {x4 : A} (r : Id x3 x4) 
  : Id ( Id.concat 
         ( Id.concat 
           ( concat f (Id.concat p q) r) 
           ( Id.whisker_right (concat f p q) (ap f r))
         ) 
         ( Id.assoc (ap f p) (ap f q) (ap f r))
       ) 
       ( Id.concat
         ( ap (@ap _ _ f x1 x4) (Id.assoc p q r))
         ( Id.concat 
           ( concat f p (Id.concat q r)) 
           ( Id.whisker_left (ap f p) (concat f q r))
         )
       ) :=
  Id.rec (Id.rec (Id.rec (Id.refl _) p) q) r

/--
  ap f (p⁻¹ ⬝ p) ======================== ap f (refl y) 
    ||                                           ||
    || ap.concat f p⁻¹ p    Id.left_inv (ap f p) ||
    ||                                           || 
  (ap f p⁻¹) ⬝ (ap f p) ========= (ap f p)⁻¹ ⬝ (ap f p)
--/

definition left_inv {A B : Type} (f : A → B) {x y : A} (p : Id x y)
  : Id ( ap (@ap _ _ f y y) (Id.left_inv p))
     ( Id.concat
       ( Id.concat
         ( concat f (Id.inv p) p)
         ( Id.whisker_right (inv f p) (ap f p)) 
       )
       ( Id.left_inv (ap f p))
     ) :=
  Id.rec (Id.refl _) p

definition right_inv {A B : Type} (f : A → B) {x y : A} (p : Id x y)
  : Id ( ap (@ap _ _ f x x) (Id.right_inv p))
     ( Id.concat
       ( Id.concat
         ( concat f p (Id.inv p))
         ( Id.whisker_left (ap f p) (inv f p))
       )
       ( Id.right_inv (ap f p))
     ) :=
  Id.rec (Id.refl _) p

definition left_unit {A B : Type} (f : A → B) {x y : A} (p : Id x y)
  : Id ( ap (@ap _ _ f x y) (Id.left_unit p))
     ( Id.concat
       ( concat f (Id.refl x) p)
       ( Id.left_unit (ap f p))
     ) :=
  Id.rec (Id.refl _) p

definition right_unit {A B : Type} (f : A → B) {x y : A} (p : Id x y)
  : Id ( ap (@ap _ _ f x y) (Id.right_unit p))
     ( Id.concat
       ( concat f p (Id.refl y))
       ( Id.right_unit (ap f p))
     ) :=
  Id.rec (Id.refl _) p

/--
In the following construction we show that ap f respects whiskering. In the 
case of left whiskering this amounts to showing that the following diagram
commutes.

                         ap (ap f) (wh_l p u)
  ap f (p ⬝ q) ======================================= ap f (p ⬝ r)
    ||                                                     ||
    || ap.concat f p q                     ap.concat f p r ||
    ||                                                     ||
  (ap f p) ⬝ (ap f q) ============================ (ap f p) ⬝ (ap f r)
                      wh_l (ap f p) (ap (ap f) u)
--/

definition whisker_left {A B : Type} (f : A → B) {x y : A} (p : Id x y) {z : A}
  {q r : Id y z} (u : Id q r)
  : Id ( Id.concat 
         ( ap (@ap _ _ f x z) (Id.whisker_left p u))
         ( concat f p r)
       )
       ( Id.concat
         ( concat f p q)
         ( Id.whisker_left (ap f p) (ap (@ap _ _ f y z) u))
       )
  :=
  Id.rec (Id.rec (Id.rec (Id.refl _) p) q) u

definition whisker_right {A B : Type} (f : A → B) {x y : A} {p q : Id x y} 
  (u : Id p q) {z : A} (r : Id y z)
  : Id ( Id.concat
         ( ap (@ap _ _ f x z) (Id.whisker_right u r))
         ( concat f q r)
       )
       ( Id.concat
         ( concat f p r)
         ( Id.whisker_right (ap (@ap _ _ f x y) u) (ap f r))
       ) 
  :=
  Id.rec (Id.rec (Id.rec (Id.refl _) p) u) r

end ap

/--
Homotopies are pointwise identifications of functions. That is, we say that two 
functions are \emph{homotopic} if we can construct a pointwise identification 
between them. Just like identifications, there is a reflexivity homotopy, and 
homotopies can be inverted, concatenated, and satisfy the groupoid laws that we 
established earlier for the identity type. However, these laws are only
satisfied up to homotopy.
--/

definition homotopy {A : Type} {B : A → Type} (f g : forall x, B x) 
  : Type :=
  forall x, Id (f x) (g x)

namespace htpy

definition refl {A : Type} {B : A → Type} (f : forall x, B x) 
  : homotopy f f :=
  λ x, Id.refl (f x)

definition inv {A : Type} {B : A → Type} {f g : forall x, B x} 
  (H : homotopy f g) 
  : homotopy g f :=
  λ x, Id.inv (H x)

definition concat {A : Type} {B : A → Type} {f g h : forall x, B x} 
  (H : homotopy f g) (K : homotopy g h) 
  : homotopy f h :=
  λ x, Id.concat (H x) (K x)

definition assoc {A : Type} {B : A → Type} {f1 f2 f3 f4 : forall x, B x} 
  (H : homotopy f1 f2) (K : homotopy f2 f3) (L : homotopy f3 f4) 
  : homotopy (concat (concat H K) L) (concat H (concat K L)) :=
  λ x, Id.assoc (H x) (K x) (L x)

definition left_inv {A : Type} {B : A → Type} {f g : forall x, B x} 
  (H : homotopy f g) 
  : homotopy (concat (inv H) H) (refl g) :=
  λ x, Id.left_inv (H x)

definition right_inv {A : Type} {B : A → Type} {f g : forall x, B x} 
  (H : homotopy f g) 
  : homotopy (concat H (inv H)) (refl f) :=
  λ x, Id.right_inv (H x)

definition left_unit {A : Type} {B : A → Type} {f g : forall x, B x} 
  (H : homotopy f g) 
  : homotopy (concat (refl f) H) H :=
  λ x, Id.left_unit (H x)

definition right_unit {A : Type} {B : A → Type} {f g : forall x, B x} 
  (H : homotopy f g) 
  : homotopy (concat H (refl g)) H :=
  λ x, Id.right_unit (H x)

definition whisker_left {A B C : Type} {f g : A → B} (h : B → C) 
  (H : homotopy f g)  
  : homotopy (λ x, h (f (x))) (λ x, h (g (x))) :=
  λ x, ap h (H x)

definition whisker_right {A B C : Type} {g h : B → C} (H : homotopy g h) 
  (f : A → B)
  : homotopy (λ x, g (f (x))) (λ x, h (f (x))) :=
  λ x, H (f x)

/--
The naturality of homotopies is the construction that for each homotopy 
H : f ~ g and each p : x = y, the square

             H x
        f x ===== g x 
         ||       ||
  ap f p ||       || ap g p
         ||       ||
        f y ===== g y
             H y

commutes.
--/

definition natural {A B : Type} {f g : A → B} (H : homotopy f g) {x y : A} 
  (p : Id x y) 
  : Id (Id.concat (H x) (ap g p)) (Id.concat (ap f p) (H y)) :=
  Id.rec (Id.concat (Id.right_unit (H x)) (Id.inv (Id.left_unit (H x)))) p

end htpy

/--
Next, we show that type families behave analogous to fibrations in homotopy 
theory. That is, we construct the transport function, that lets us transport a 
term from one fiber to another over an identification in the base type. 
Moreover, we construct a \emph{path lifting} operation, that lifts an 
identification in the base type to an identification in the dependent pair 
type, starting at any given point in the fiber.
--/

definition transport {A : Type} {B : A → Type} {x y : A} (p : Id x y) 
  : B x → B y :=
  Id.rec (λ b, b) p

namespace tr

definition refl {A : Type} {B : A → Type} (x : A) : B x → B x :=
  λ b, b

definition concat_compute {A : Type} {B : A → Type} {x y : A} (p : Id x y) {z : A} 
  (q : Id y z) 
  : B x → B z :=
  λ b, transport q (transport p b)

definition concat {A : Type} {B : A → Type} {x y : A} (p : Id x y) 
  {z : A} (q : Id y z)
  : homotopy (concat_compute p q) (transport (Id.concat p q)) :=
  Id.rec (Id.rec (λ (b : B x), Id.refl _) p) q

definition inv_compute {A : Type} {B : A → Type} {x y : A} (p : Id x y)  
  : B y → B x :=
  Id.rec (λ b, b) p

definition inv {A : Type} {B : A → Type} {x y : A} (p : Id x y) 
  : homotopy (inv_compute p) (transport (Id.inv p)) :=
  Id.rec (λ (b : B x), Id.refl b) p

definition assoc {A : Type} {B : A → Type} {x1 x2 : A} (p : Id x1 x2) 
  {x3 : A} (q : Id x2 x3) {x4 : A} (r : Id x3 x4) 
  : homotopy (concat_compute (Id.concat p q) r) 
             (concat_compute p (Id.concat q r)) :=
  Id.rec (Id.rec (Id.rec (λ (b : B x1), Id.refl _) p) q) r

definition fun_rel {A B : Type} (f : A → B) {x y : A} (p : Id x y) {b : B}
  (q : Id (f x) b) : Id (transport p q) (Id.concat (Id.inv (ap f p)) q) :=
  Id.rec (Id.rec (Id.refl _) p) q

definition fun_rel' {A B : Type} (f : A → B) {x y : A} (p : Id x y) {b : B}
  (q : Id b (f x)) : Id (transport p q) (Id.concat q (ap f p)) :=
  Id.rec (Id.rec (Id.refl _) p) q
  

end tr

definition apd {A : Type} {B : A → Type} (f : forall x, B x) {x y : A} 
  (p : Id x y) 
  : Id (transport p (f x)) (f y) :=
  Id.rec (Id.refl (f x)) p

namespace square
/--
When we make constructions of higher identities, we soon run into commuting 
squares. A square

       ptop  
  x00 ====== x01
   ||         ||
   || pleft   || pright
   ||         ||
  x10 ====== x11
       pbot

is said to commute, if we can construct an identification of type

  Id (Id.concat ptop pright) (Id.concat pleft pbot).

Some basic manipulations on commuting squares include the whiskering 
operations.
--/

definition whisker_top {A : Type} {x00 x01 x10 x11 : A}
  {ptop ptop' : Id x00 x01} (q : Id ptop ptop')
  : Π {pright : Id x01 x11} {pleft : Id x00 x10} {pbot : Id x10 x11}
  (sq : Id (Id.concat ptop pright) (Id.concat pleft pbot)),
  Id (Id.concat ptop' pright) (Id.concat pleft pbot)
  :=
  Id.rec (λ pright pleft pbot sq, sq) q

definition whisker_right {A : Type} {x00 x01 x10 x11 : A} 
  {ptop : Id x00 x01} 
  {pright pright' : Id x01 x11} (q : Id pright pright') 
  
  : forall {pleft : Id x00 x10} {pbot : Id x10 x11}, 
  Id (Id.concat ptop pright) (Id.concat pleft pbot) 
  → Id (Id.concat ptop pright') (Id.concat pleft pbot)
  :=
  Id.rec (λ pw ps sq, sq) q

definition whisker_left {A : Type} {x00 x01 x10 x11 : A}
  {ptop : Id x00 x01}
  {pright : Id x01 x11}
  {pleft pleft' : Id x00 x10} (q : Id pleft pleft')
  : Π {pbot : Id x10 x11}, 
    Id (Id.concat ptop pright) (Id.concat pleft pbot)
    → Id (Id.concat ptop pright) (Id.concat pleft' pbot) :=
  Id.rec (λ pbot sq, sq) q

definition whisker_bot {A : Type} {x00 x01 x10 x11 : A}
  {ptop : Id x00 x01}
  {pright : Id x01 x11}
  {pleft : Id x00 x10}
  {pbot pbot' : Id x10 x11} (q : Id pbot pbot')
  : Id (Id.concat ptop pright) (Id.concat pleft pbot)
    → Id (Id.concat ptop pright) (Id.concat pleft pbot') :=
  Id.rec (λ sq, sq) q

end square

namespace int
/--
We prove some basic properties of operations on the integers
--/

/--
definition pred_neg_succ : Π (n : nat), Id (pred (neg n)) (neg (nat.succ n)) :=
  nat.rec (Id.refl _) (λ n p, _)

definition pred_is_retr : homotopy (λ k, pred (succ k)) (λ k, k) :=
  destruct_full
    (Id.refl _)
    (λ n p, Id.concat _ (ap pred p))
    _
    _
    _

definition assoc_add 
  : Π (k l m : int), Id (add k (add l m)) (add (add k l) m) :=
  int.destruct 
    ( nat.rec 
      ( int.destruct 
        ( nat.rec 
          ( int.destruct 
            ( nat.rec (Id.refl _) 
              ( λ m assoc_negk_negl_negm, ap pred assoc_negk_negl_negm)
            ) 
            ( unit.rec (Id.refl _) unit.tt) 
            ( nat.rec (Id.refl _)
              ( λ m assoc_negk_negl_posm, _)
            )
          ) 
          _
        ) 
        _ _
      )
      ( _)
    ) 
    ( _)
    ( _)

--/

end int
