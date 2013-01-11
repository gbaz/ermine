--------------------------------------------------------------------
-- |
-- Module    :  Ermine
-- Copyright :  (c) Edward Kmett 2011-12
-- License   :  BSD3
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: non-portable
--
-- This module provides a single export with most of the types
-- and terms involved (modulo conflicts) for easy testing
--------------------------------------------------------------------
module Ermine
  ( module Ermine.Builtin.Type
  , module Ermine.Diagnostic
  , module Ermine.Inference.Kind
  , module Ermine.Parser.Kind
  , module Ermine.Syntax
  , module Ermine.Syntax.Core
  , module Ermine.Syntax.Digest
  , module Ermine.Syntax.Global
  , module Ermine.Syntax.Kind
  , module Ermine.Syntax.Pat
  , module Ermine.Syntax.Prim
  , module Ermine.Syntax.Scope
  , module Ermine.Syntax.Term
  , module Ermine.Syntax.Type
  , module Ermine.Unification.Kind
  , module Ermine.Unification.Meta
  , module Ermine.Unification.Type
  , module Ermine.Version
  ) where

import Ermine.Builtin.Type
import Ermine.Diagnostic
import Ermine.Inference.Kind
import Ermine.Parser.Kind
import Ermine.Syntax
import Ermine.Syntax.Core hiding (Var, App, Let, Case, Lam, Prim)
import Ermine.Syntax.Digest
import Ermine.Syntax.Global
import Ermine.Syntax.Kind hiding (Var)
import Ermine.Syntax.Pat
import Ermine.Syntax.Prim
import Ermine.Syntax.Scope
import Ermine.Syntax.Term hiding (Var, App, Loc)
import Ermine.Syntax.Type hiding (Var, App, Loc, Tuple)
import Ermine.Unification.Kind
import Ermine.Unification.Meta
import Ermine.Unification.Type
import Ermine.Version
