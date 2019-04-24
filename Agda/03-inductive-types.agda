{-# OPTIONS --without-K #-}

module 03-inductive-types where

import 02-natural-numbers
open 02-natural-numbers public

data unit : UU lzero where
  star : unit
  
𝟙 = unit

ind-unit : {i : Level} {P : unit → UU i} → P star → ((x : unit) → P x)
ind-unit p star = p

data empty : UU lzero where

𝟘 = empty

ind-empty : {i : Level} {P : empty → UU i} → ((x : empty) → P x)
ind-empty ()

¬ : {i : Level} → UU i → UU i
¬ A = A → empty

data bool : UU lzero where
  true false : bool

data coprod {i j : Level} (A : UU i) (B : UU j) : UU (i ⊔ j)  where
  inl : A → coprod A B
  inr : B → coprod A B

ind-coprod : {i j k : Level} {A : UU i} {B : UU j} (C : coprod A B → UU k) →
  ((x : A) → C (inl x)) → ((y : B) → C (inr y)) →
  (t : coprod A B) → C t
ind-coprod C f g (inl x) = f x
ind-coprod C f g (inr x) = g x

data Σ {i j : Level} (A : UU i) (B : A → UU j) : UU (i ⊔ j) where
  pair : (x : A) → (B x → Σ A B)

ind-Σ : {i j k : Level} {A : UU i} {B : A → UU j} {C : Σ A B → UU k} →
  ((x : A) (y : B x) → C (pair x y)) → ((t : Σ A B) → C t)
ind-Σ f (pair x y) = f x y

pr1 : {i j : Level} {A : UU i} {B : A → UU j} → Σ A B → A
pr1 (pair a b) = a

pr2 : {i j : Level} {A : UU i} {B : A → UU j} → (t : Σ A B) → B (pr1 t)
pr2 (pair a b) = b

prod : {i j : Level} (A : UU i) (B : UU j) → UU (i ⊔ j)
prod A B = Σ A (λ a → B)

pair' :
  {i j : Level} {A : UU i} {B : UU j} → A → B → prod A B
pair' = pair

_×_ :  {i j : Level} (A : UU i) (B : UU j) → UU (i ⊔ j)
A × B = prod A B

-- The integers
ℤ : UU lzero
ℤ = coprod ℕ (coprod unit ℕ)

-- Inclusion of the negative integers
in-neg : ℕ → ℤ
in-neg n = inl n

-- Negative one
neg-one-ℤ : ℤ
neg-one-ℤ = in-neg zero-ℕ

-- Zero
zero-ℤ : ℤ
zero-ℤ = inr (inl star)

-- One
one-ℤ : ℤ
one-ℤ = inr (inr zero-ℕ)

-- Inclusion of the positive integers
in-pos : ℕ → ℤ
in-pos n = inr (inr n)

ind-ℤ : {i : Level} (P : ℤ → UU i) → P neg-one-ℤ → ((n : ℕ) → P (inl n) → P (inl (succ-ℕ n))) → P zero-ℤ → P one-ℤ → ((n : ℕ) → P (inr (inr (n))) → P (inr (inr (succ-ℕ n)))) → (k : ℤ) → P k
ind-ℤ P p-1 p-S p0 p1 pS (inl zero-ℕ) = p-1
ind-ℤ P p-1 p-S p0 p1 pS (inl (succ-ℕ x)) = p-S x (ind-ℤ P p-1 p-S p0 p1 pS (inl x))
ind-ℤ P p-1 p-S p0 p1 pS (inr (inl star)) = p0
ind-ℤ P p-1 p-S p0 p1 pS (inr (inr zero-ℕ)) = p1
ind-ℤ P p-1 p-S p0 p1 pS (inr (inr (succ-ℕ x))) = pS x (ind-ℤ P p-1 p-S p0 p1 pS (inr (inr (x))))

succ-ℤ : ℤ → ℤ
succ-ℤ (inl zero-ℕ) = zero-ℤ
succ-ℤ (inl (succ-ℕ x)) = inl x
succ-ℤ (inr (inl star)) = one-ℤ
succ-ℤ (inr (inr x)) = inr (inr (succ-ℕ x))

-- Exercise 3.9
-- In this exercise we were asked to show that 1 + 1 satisfies the induction principle of the booleans. In other words, type theory cannot distinguish the booleans from the type 1 + 1. We will see later that they are indeed equivalent types.
t0 : coprod unit unit
t0 = inl star

t1 : coprod unit unit
t1 = inr star

ind-coprod-unit-unit : {i : Level} {P : coprod unit unit → UU i} →
  P t0 → P t1 → (x : coprod unit unit) → P x
ind-coprod-unit-unit p0 p1 (inl star) = p0
ind-coprod-unit-unit p0 p1 (inr star) = p1

-- Exercise 3.11
pred-ℤ : ℤ → ℤ
pred-ℤ (inl x) = inl (succ-ℕ x)
pred-ℤ (inr (inl star)) = inl zero-ℕ
pred-ℤ (inr (inr zero-ℕ)) = inr (inl star)
pred-ℤ (inr (inr (succ-ℕ x))) = inr (inr x)

-- Exercise 3.12
add-ℤ : ℤ → ℤ → ℤ
add-ℤ (inl zero-ℕ) l = pred-ℤ l
add-ℤ (inl (succ-ℕ x)) l = pred-ℤ (add-ℤ (inl x) l)
add-ℤ (inr (inl star)) l = l
add-ℤ (inr (inr zero-ℕ)) l = succ-ℤ l
add-ℤ (inr (inr (succ-ℕ x))) l = succ-ℤ (add-ℤ (inr (inr x)) l)

neg-ℤ : ℤ → ℤ
neg-ℤ (inl x) = inr (inr x)
neg-ℤ (inr (inl star)) = inr (inl star)
neg-ℤ (inr (inr x)) = inl x

-- Multiplication on ℤ

mul-ℤ : ℤ → ℤ → ℤ
mul-ℤ (inl zero-ℕ) l = neg-ℤ l
mul-ℤ (inl (succ-ℕ x)) l = add-ℤ (neg-ℤ l) (mul-ℤ (inl x) l)
mul-ℤ (inr (inl star)) l = zero-ℤ
mul-ℤ (inr (inr zero-ℕ)) l = l
mul-ℤ (inr (inr (succ-ℕ x))) l = add-ℤ l (mul-ℤ (inr (inr x)) l)

-- Extend the Fibonacci sequence to ℤ in the obvious way
Fibonacci-ℤ : ℤ → ℤ
Fibonacci-ℤ (inl zero-ℕ) = one-ℤ
Fibonacci-ℤ (inl (succ-ℕ zero-ℕ)) = neg-one-ℤ
Fibonacci-ℤ (inl (succ-ℕ (succ-ℕ x))) =
  add-ℤ (Fibonacci-ℤ (inl x)) (neg-ℤ (Fibonacci-ℤ (inl (succ-ℕ x))))
Fibonacci-ℤ (inr (inl star)) = zero-ℤ
Fibonacci-ℤ (inr (inr zero-ℕ)) = one-ℤ
Fibonacci-ℤ (inr (inr (succ-ℕ zero-ℕ))) = one-ℤ
Fibonacci-ℤ (inr (inr (succ-ℕ (succ-ℕ x)))) =
  add-ℤ (Fibonacci-ℤ (inr (inr x))) (Fibonacci-ℤ (inr (inr (succ-ℕ x))))
