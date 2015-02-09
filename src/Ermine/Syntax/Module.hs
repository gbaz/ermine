{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE TemplateHaskell #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) McGraw Hill Financial 2013, 2014
-- License   :  BSD2
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: non-portable
--
-- Data structures representing parsed modules and their components,
-- aside from those already in 'Ermine.Syntax.Term' et al.
--------------------------------------------------------------------
module Ermine.Syntax.Module where

import Control.Applicative ((<$>), (<*>))
import Control.Lens
import Data.Bytes.Serial
import Data.Bifoldable
import Data.Binary
import Data.Bitraversable
import Data.Foldable (Foldable)
import Data.Map (Map)
import Data.Serialize
import Data.Data hiding (DataType)
import Data.Ix
import Data.Text
import Data.Void
import Ermine.Builtin.Term (PreBody())
import Ermine.Syntax.Class
import Ermine.Syntax.Data
import Ermine.Syntax.Global as Global
import Ermine.Syntax.ModuleName
import Ermine.Syntax.Term
import Ermine.Syntax.Type
import GHC.Generics hiding (moduleName)

-- | Whether a name is visible to importers of a module, or a module
-- is reexported from its importer.
data Privacy = Private | Public deriving (Eq,Ord,Show,Read,Enum,Bounded,Ix,Generic,Typeable,Data)

instance Serial Privacy

instance Binary Privacy where
  put = serialize
  get = deserialize

instance Serialize Privacy where
  put = serialize
  get = deserialize

-- | An explicitly-listed name in an import/export statement.
data Explicit g = Explicit
  { _explicitGlobal :: g            -- ^ the full original name
  , _explicitIsType :: Bool         -- ^ whether to import a type, not term
  , _explicitLocal  :: Maybe String -- ^ the 'as' renaming, if any
  } deriving (Eq,Ord,Show,Read,Functor,Foldable,Traversable,Typeable)

makeClassy ''Explicit

data ImportsInScope g =
    Using  [Explicit g]  -- ^ list of names requested to import
  | Hiding [Explicit g]  -- ^ list of names requested to hide (hiding [] == import everything)
  deriving (Eq,Ord,Show,Read,Functor,Foldable,Traversable,Typeable)

makeClassyPrisms ''ImportsInScope

importScopeExplicits :: Lens (ImportsInScope g) (ImportsInScope h) [Explicit g] [Explicit h]
importScopeExplicits f (Using ex) = Using <$> f ex
importScopeExplicits f (Hiding ex) = Hiding <$> f ex

-- | An import/export statement.
data Import g = Import -- TODO: add a location
  { _importPrivacy   :: Privacy         -- ^ whether to reexport the symbols
  , _importModule    :: ModuleName      -- ^ what module to import
  , _importAs        :: Maybe String    -- ^ the 'as' qualifier suffix
  , _importScope     :: ImportsInScope g -- ^ what imports are brought into scope
  } deriving (Eq,Ord,Show,Read,Functor,Foldable,Traversable,Typeable)

makeClassy ''Import

-- | A type-changing alternative to the classy lenses.
importScope' :: Lens (Import g) (Import h) (ImportsInScope g) (ImportsInScope h)
importScope' f (imp@Import {_importScope = sc}) =
  f sc <&> \sc' -> imp {_importScope = sc'}

-- | A fixity declaration statement.
data FixityDecl = FixityDecl
  { _fixityDeclType   :: Bool          -- ^ whether these are type operators
  , _fixityDeclFixity :: Global.Fixity -- ^ direction & precedence
  , _fixityDeclNames  :: [Text]        -- ^ the names to assign fixities to
  } deriving (Show, Eq, Data, Typeable)

makeClassy ''FixityDecl

{-
data InstanceDecl = InstanceDecl
  { _instanceDeclClass    :: Class
  , _instanceDeclDefaults :: ClassBinding
  } deriving (Show, Typeable)
-}

-- | Combine top-level statements into a single type.
data Statement t a = FixityDeclStmt FixityDecl
                   | DataTypeStmt Privacy (DataType () t)
                   | SigStmt Privacy [a] (Annot Void t)
                   | TermStmt Privacy a [PreBody (Annot Void t) a]
                   | ClassStmt a (Class () t)
  deriving (Show, Eq)

makeClassyPrisms ''Statement

data Module = Module
  { _moduleName      :: ModuleName
  , _moduleImports   :: [Import Global]
  , _moduleFixities  :: [FixityDecl]
  , _moduleData      :: [(Privacy, DataType () Text)] -- TODO: support type not just data
  , _moduleBindings  :: [(Privacy, Text, Binding (Annot Void Text) Text)]
  , _moduleClasses   :: Map Text (Class () Text)
  -- , _moduleInstances :: Map Head () 
  } deriving (Show, Typeable)

makeClassy ''Module

class HasFixities a where
  fixityDecls :: Lens' a [FixityDecl]

instance (a ~ FixityDecl) => HasFixities [a] where
  fixityDecls = id

instance HasFixities Module where
  fixityDecls = moduleFixities

-- | The part of the module we can parse without knowing what's in the
-- imported/exported modules, and the remainder text.
data ModuleHead imp txt = ModuleHead
  { _moduleHeadName :: ModuleName
  , _moduleHeadImports :: [imp]
  , _moduleHeadText :: txt }
  deriving (Eq, Ord, Show, Read, Data, Functor, Foldable, Traversable,
            Generic, Typeable)

makeClassy ''ModuleHead

instance HasModuleName (ModuleHead imp txt) where
  module_ = moduleHeadName

instance Bifunctor ModuleHead where
  bimap = bimapDefault

instance Bifoldable ModuleHead where
  bifoldMap = bifoldMapDefault

instance Bitraversable ModuleHead where
  bitraverse f g (ModuleHead n im tx) =
    ModuleHead n <$> traverse f im <*> g tx
