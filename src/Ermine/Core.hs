{-# LANGUAGE DeriveFunctor, DeriveFoldable, DeriveTraversable, MultiParamTypeClasses #-}
{-# OPTIONS_GHC -funbox-strict-fields #-}
--------------------------------------------------------------------
-- |
-- Module    :  Ermine.Core
-- Copyright :  (c) Edward Kmett 2012
-- License   :  BSD3
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: non-portable
--------------------------------------------------------------------

module Ermine.Core
  (
  -- * Core Terms
    Core(..)
  , Lit(..)
  -- * Smart patterns
  , P
  , varp
  , _p
  , strictp
  , lazyp
  , asp
  , primp
  -- * Smart constructors
  , lam
  , let_
  , alt
  -- * Common built-in terms
  , cons, nil
  , just, nothing
  ) where

import Bound
import Control.Applicative
import Control.Monad
import Control.Lens
import Data.Int
import Data.List hiding (foldr)
import Data.Foldable
import Data.String
import Ermine.Global
import Ermine.Pat
import Ermine.Prim
import Ermine.Scope
import Ermine.Syntax
import Prelude.Extras
import Prelude hiding (foldr)

-- $setup
-- >>> import Text.Groom

infixr 5 `cons`

-- | The built-in '::' constructor for a list.
--
-- >>> putStrLn $ groom $ lit (1 :: Int) `cons` nil
-- Prim (DataCon (global (Infix R 5) "ermine" "Builtin" "::"))
--   [Prim (Int 1) [],
--    Prim (DataCon (global Idfix "ermine" "Builtin" "Nil")) []]
cons :: Core a -> Core a -> Core a
cons a as = Prim (prim (Infix R 5) "Builtin" "::") [a,as]

-- | The built-in '[]' constructor for a list.
nil :: Core a
nil = Prim (prim Idfix "Builtin" "Nil") []

-- | The built-in 'Just' constructor for 'Maybe'.
just :: Core a -> Core a
just a = Prim (prim Idfix "Builtin" "Just") [a]

-- | The built-in 'Nothing' constructor for 'Maybe'.
nothing :: Core a
nothing = Prim (prim Idfix "Builtin" "Nothing") []

-- | Lifting of literal values to core.
class Lit a where
  lit  :: a   -> Core b
  lits :: [a] -> Core b
  lits = foldr (cons . lit) nil

instance Lit Int64 where lit l = Prim (Int64 l) []
instance Lit Int where lit i = Prim (Int i) []
instance Lit Char where
  lit c = Prim (Char c) []
  lits s = Prim (String s) []
instance Lit Int8 where lit b = Prim (Byte b) []
instance Lit Int16 where lit s = Prim (Short s) []
instance (Lit a, Lit b) => Lit (a, b) where
  lit (a,b) = Prim (Tuple 2) [lit a, lit b]
instance Lit a => Lit [a] where
  lit = lits
instance Lit a => Lit (Maybe a) where
  lit = maybe nothing (just . lit)

instance Num (Core a) where
  a + b = Prim (prim (Infix L 6) "Builtin" "+") [a,b]
  a - b = Prim (prim (Infix L 6) "Builtin" "-") [a,b]
  a * b = Prim (prim (Infix L 7) "Builtin" "*") [a,b]
  negate a     = Prim (prim Idfix "Builtin" "negate") [a]
  abs a        = Prim (prim Idfix "Builtin" "abs")    [a]
  signum a     = Prim (prim Idfix "Builtin" "signum") [a]
  fromInteger i = Prim (Int (fromInteger i)) []

-- | Core values are the output of the compilation process.
--
-- They are terms where the dictionary passing has been made explicit
-- and all of the types have been checked and removed.
data Core a
  = Var a
  | Prim !Prim [Core a]
  | App !(Core a) !(Core a)
  | Lam !(Pat ()) !(Scope Int Core a)
  | Let [Scope Int Core a] !(Scope Int Core a)
  | Case !(Core a) [Alt () Core a]
  deriving (Eq,Show,Functor,Foldable,Traversable)

instance IsString a => IsString (Core a) where
  fromString = Var . fromString

instance App Core where
  app = prism (uncurry App) $ \t -> case t of
    App l r -> Right (l,r)
    _       -> Left t

instance Variable Core where
  var = prism Var $ \t -> case t of
    Var a -> Right a
    _     -> Left t

instance Applicative Core where
  pure = Var
  (<*>) = ap

instance Monad Core where
  return = Var
  Var a      >>= f = f a
  Prim k xs  >>= f = Prim k (map (>>= f) xs)
  App x y    >>= f = App (x >>= f) (y >>= f)
  Lam p e    >>= f = Lam p (boundBy f e)
  Let bs e   >>= f = Let (map (boundBy f) bs) (boundBy f e)
  Case e as  >>= f = Case (e >>= f) (map (>>>= f) as)

instance Eq1 Core
instance Show1 Core

-- | Smart Pattern
data P a = P { pattern :: Pat (), bindings :: [a] } deriving Show

-- | A pattern that binds a variable.
varp :: a -> P a
varp a = P VarP [a]

-- | A wildcard pattern that ignores its argument
_p :: P a
_p = P WildcardP []

-- | A strict (bang) pattern
strictp :: P a -> P a
strictp (P p bs) = P (StrictP p) bs

-- | A lazy (irrefutable) pattern
lazyp :: P a -> P a
lazyp (P p bs) = P (LazyP p) bs

-- | An as @(\@)@ pattern.
asp :: a -> P a -> P a
asp a (P p as) = P (AsP p) (a:as)

-- | A pattern that matches a primitive expression.
primp :: Prim -> [P a] -> P a
primp g ps = P (PrimP g (map pattern ps)) (ps >>= bindings)

-- | smart lam constructor
lam :: Eq a => P a -> Core a -> Core a
lam (P p as) t = Lam p (abstract (`elemIndex` as) t)

-- | smart let constructor
let_ :: Eq a => [(a, Core a)] -> Core a -> Core a
let_ bs b = Let (map (abstr . snd) bs) (abstr b)
  where vs  = map fst bs
        abstr = abstract (`elemIndex` vs)

-- | smart alt constructor
alt :: Eq a => P a -> Core a -> Alt () Core a
alt (P p as) t = Alt p (abstract (`elemIndex` as) t)