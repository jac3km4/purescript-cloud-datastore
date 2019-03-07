module Database.Datastore.Types where

import Data.Nullable (Nullable)

foreign import data Client :: Type

foreign import data PathElement :: Type

foreign import data Query :: Type

foreign import data FilterOperator :: Type

type ClientOptions =
  { apiEndpoint :: Nullable String
  , namespace :: Nullable String
  , projectId :: Nullable String
  , keyFilename :: Nullable String
  }

type KeyOptions =
  { namespace :: Nullable String, path :: Array PathElement }

type QueryOptions =
  { consistency :: Nullable String, maxApiCalls :: Nullable Int }

type Payload a =
  { key :: Key
  , data :: a
  , excludeFromIndexes :: Array String
  }

type MutationResult =
  { key :: { path :: Array { kind :: String, id :: String } }
  , conflictDetected :: Boolean
  , version :: String
  }

type CommitResponse =
  { mutationResults :: Array MutationResult, indexUpdates :: Int }

type QueryInfo = { endCursor :: Nullable String }

newtype Key = Key
  { kind :: Nullable Kind
  , id :: Nullable String
  , name :: Nullable String
  , path :: Array PathElement
  , parent :: Nullable Key
  }

newtype Kind = Kind String

newtype Property = Property String
