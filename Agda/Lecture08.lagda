\begin{code}

{-# OPTIONS --without-K --allow-unsolved-metas #-}

module Lecture08 where

import Lecture07
open Lecture07 public

-- Section 8.1 Propositions

is-prop : {i : Level} (A : UU i) → UU i
is-prop A = (x y : A) → is-contr (Id x y)

is-prop-empty : is-prop empty
is-prop-empty ()

is-prop-unit : is-prop unit
is-prop-unit = is-prop-is-contr is-contr-unit

is-prop' : {i : Level} (A : UU i) → UU i
is-prop' A = (x y : A) → Id x y

is-prop-is-prop' : {i : Level} {A : UU i} → is-prop' A → is-prop A
is-prop-is-prop' {i} {A} H x y =
  dpair
    (concat _ (inv (H x x)) (H x y))
    (ind-Id x
      (λ z p → Id (concat _ (inv (H x x)) (H x z)) p)
      (left-inv (H x x)) y)

is-prop'-is-prop : {i : Level} {A : UU i} → is-prop A → is-prop' A
is-prop'-is-prop H x y = pr1 (H x y)

is-contr-is-prop-inh : {i : Level} {A : UU i} → is-prop A → A → is-contr A
is-contr-is-prop-inh H a = dpair a (is-prop'-is-prop H a)

is-subtype : {i j : Level} {A : UU i} (B : A → UU j) → UU (i ⊔ j)
is-subtype B = (x : _) → is-prop (B x)

-- Section 8.2 Sets

is-set : {i : Level} → UU i → UU i
is-set A = (x y : A) → is-prop (Id x y)

axiom-K : {i : Level} → UU i → UU i
axiom-K A = (x : A) (p : Id x x) → Id refl p

is-set-axiom-K : {i : Level} (A : UU i) → axiom-K A → is-set A
is-set-axiom-K A H x y =
  is-prop-is-prop' (ind-Id x (λ z p → (q : Id x z) → Id p q) (H x) y)

axiom-K-is-set : {i : Level} (A : UU i) → is-set A → axiom-K A
axiom-K-is-set A H x p =
  concat
    (center (is-contr-is-prop-inh (H x x) refl))
      (inv (contraction (is-contr-is-prop-inh (H x x) refl) refl))
      (contraction (is-contr-is-prop-inh (H x x) refl) p)

is-equiv-prop-in-id : {i j : Level} {A : UU i}
  (R : A → A → UU j)
  (p : (x y : A) → is-prop (R x y))
  (ρ : (x : A) → R x x)
  (i : (x y : A) → R x y → Id x y)
  → (x y : A) → is-equiv (i x y)
is-equiv-prop-in-id R p ρ i x =
  id-fundamental-retr x (i x)
    (λ y → dpair
      (ind-Id x (λ z p → R x z) (ρ x) y)
      ((λ r → is-prop'-is-prop (p x y) _ r)))

is-prop-is-equiv : {i j : Level} {A : UU i} (B : UU j)
  (f : A → B) (E : is-equiv f) → is-prop B → is-prop A
is-prop-is-equiv B f E H x y =
  is-contr-is-equiv _ (ap f {x} {y}) (is-emb-is-equiv f E x y) (H (f x) (f y))

is-prop-is-equiv' : {i j : Level} (A : UU i) {B : UU j}
  (f : A → B) (E : is-equiv f) → is-prop A → is-prop B
is-prop-is-equiv' A f E H =
  is-prop-is-equiv _ (inv-is-equiv E) (is-equiv-inv-is-equiv E) H

is-set-prop-in-id : {i j : Level} {A : UU i}
  (R : A → A → UU j)
  (p : (x y : A) → is-prop (R x y))
  (ρ : (x : A) → R x x)
  (i : (x y : A) → R x y → Id x y)
  → is-set A
is-set-prop-in-id R p ρ i x y = is-prop-is-equiv' (R x y) (i x y) (is-equiv-prop-in-id R p ρ i x y) (p x y)

is-prop-Eq-ℕ : (n m : ℕ) → is-prop (Eq-ℕ n m)
is-prop-Eq-ℕ zero-ℕ zero-ℕ = is-prop-unit
is-prop-Eq-ℕ zero-ℕ (succ-ℕ m) = is-prop-empty
is-prop-Eq-ℕ (succ-ℕ n) zero-ℕ = is-prop-empty
is-prop-Eq-ℕ (succ-ℕ n) (succ-ℕ m) = is-prop-Eq-ℕ n m

is-set-nat : is-set ℕ
is-set-nat =
  is-set-prop-in-id
    Eq-ℕ
    is-prop-Eq-ℕ
    reflexive-Eq-ℕ
    (least-reflexive-Eq-ℕ (λ n → refl))

-- Section 8.3 General truncation levels

data 𝕋 : U where
  neg-two-𝕋 : 𝕋
  succ-𝕋 : 𝕋 → 𝕋

neg-one-𝕋 : 𝕋
neg-one-𝕋 = succ-𝕋 (neg-two-𝕋)

zero-𝕋 : 𝕋
zero-𝕋 = succ-𝕋 (neg-one-𝕋)

one-𝕋 : 𝕋
one-𝕋 = succ-𝕋 (zero-𝕋)

ℕ-in-𝕋 : ℕ → 𝕋
ℕ-in-𝕋 zero-ℕ = zero-𝕋
ℕ-in-𝕋 (succ-ℕ n) = succ-𝕋 (ℕ-in-𝕋 n)

-- Probably it is better to define this where we first need it.
add-𝕋 : 𝕋 → 𝕋 → 𝕋
add-𝕋 neg-two-𝕋 neg-two-𝕋 = neg-two-𝕋
add-𝕋 neg-two-𝕋 (succ-𝕋 neg-two-𝕋) = neg-two-𝕋
add-𝕋 neg-two-𝕋 (succ-𝕋 (succ-𝕋 y)) = y
add-𝕋 (succ-𝕋 neg-two-𝕋) neg-two-𝕋 = neg-two-𝕋
add-𝕋 (succ-𝕋 neg-two-𝕋) (succ-𝕋 y) = y
add-𝕋 (succ-𝕋 (succ-𝕋 neg-two-𝕋)) y = y
add-𝕋 (succ-𝕋 (succ-𝕋 (succ-𝕋 x))) y = succ-𝕋 (add-𝕋 (succ-𝕋 (succ-𝕋 x)) y)

is-trunc : {i : Level} (k : 𝕋) → UU i → UU i
is-trunc neg-two-𝕋 A = is-contr A
is-trunc (succ-𝕋 k) A = (x y : A) → is-trunc k (Id x y)
  
is-trunc-succ-is-trunc : {i : Level} (k : 𝕋) (A : UU i) →
  is-trunc k A → is-trunc (succ-𝕋 k) A
is-trunc-succ-is-trunc neg-two-𝕋 A H = is-prop-is-contr H
is-trunc-succ-is-trunc (succ-𝕋 k) A H =
  λ x y → is-trunc-succ-is-trunc k (Id x y) (H x y)

is-trunc-is-equiv : {i j : Level} (k : 𝕋) {A : UU i} {B : UU j}
  (f : A → B) → is-equiv f → is-trunc k B → is-trunc k A
is-trunc-is-equiv neg-two-𝕋 f Ef H = is-contr-is-equiv _ f Ef H
is-trunc-is-equiv (succ-𝕋 k) f Ef H x y =
  is-trunc-is-equiv k (ap f {x} {y})
    (is-emb-is-equiv f Ef x y) (H (f x) (f y))

is-trunc-succ-is-emb : {i j : Level} (k : 𝕋) {A : UU i} {B : UU j}
  (f : A → B) → is-emb f → is-trunc (succ-𝕋 k) B → is-trunc (succ-𝕋 k) A
is-trunc-succ-is-emb k f Ef H x y =
  is-trunc-is-equiv k (ap f {x} {y}) (Ef x y) (H (f x) (f y))

is-trunc-map : {i j : Level} (k : 𝕋) {A : UU i} {B : UU j} →
  (A → B) → UU (i ⊔ j)
is-trunc-map k f = (y : _) → is-trunc k (fib f y)

is-trunc-pr1-is-trunc-fam : {i j : Level} (k : 𝕋) {A : UU i} (B : A → UU j) →
  ((x : A) → is-trunc k (B x)) → is-trunc-map k (pr1 {i} {j} {A} {B})
is-trunc-pr1-is-trunc-fam k B H x =
  is-trunc-is-equiv k
    ( fib-fam-fib-pr1 B x)
    ( is-equiv-fib-fam-fib-pr1 B x)
    ( H x)

is-trunc-fam-is-trunc-pr1 : {i j : Level} (k : 𝕋) {A : UU i} (B : A → UU j) →
  is-trunc-map k (pr1 {i} {j} {A} {B}) → ((x : A) → is-trunc k (B x))
is-trunc-fam-is-trunc-pr1 k B is-trunc-pr1 x =
  is-trunc-is-equiv k
    ( fib-pr1-fib-fam B x)
    ( is-equiv-fib-pr1-fib-fam B x)
    ( is-trunc-pr1 x)

\end{code}
