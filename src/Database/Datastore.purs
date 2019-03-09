module Database.Datastore
  ( module Database.Datastore.Types
  , defaultClientOpts
  , defaultQueryOpts
  , connect
  , createQuery
  , delete
  , save
  , get
  , keyById
  ) where

import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, notNull, null, toMaybe)
import Database.Datastore.Types (Client, ClientOptions, CommitResponse, Key(..), Kind, Payload, Query, QueryInfo, QueryOptions)
import Effect (Effect)
import Effect.Aff (Aff, error, makeAff, nonCanceler)
import Effect.Exception (Error)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, EffectFn4, mkEffectFn2, runEffectFn1, runEffectFn3, runEffectFn4)
import Foreign (Foreign)
import Prelude (Unit, const, show, ($), (<$), (<<<))
import Simple.JSON (class ReadForeign, class WriteForeign, read, write)

defaultClientOpts :: ClientOptions
defaultClientOpts =
  { apiEndpoint: null, namespace: null, projectId: null, keyFilename: null }

defaultQueryOpts :: QueryOptions
defaultQueryOpts = { consistency: null, maxApiCalls: null }

connect :: ClientOptions -> Effect Client
connect opts = runEffectFn1 _connect opts

createQuery :: Client -> Kind -> Query
createQuery cli kind = runFn2 _createQuery cli kind

delete :: Client -> Key -> Aff CommitResponse
delete cli key = makeAff \cb ->
  nonCanceler <$ runEffectFn3 _delete cli key (mkEffectFn2 $ const $ cb <<< Right)

save :: ∀ a. WriteForeign a => Client -> Payload a -> Aff CommitResponse
save cli payload = makeAff \cb ->
  nonCanceler <$ runEffectFn3 _save cli body (mkEffectFn2 $ const $ cb <<< Right)
  where
    body = payload { data = write payload.data }

get :: ∀ a. ReadForeign a => Client -> Key -> QueryOptions -> Aff (Maybe a)
get cli key opts = makeAff \cb ->
  nonCanceler <$ runEffectFn4 _get cli key opts (mkEffectFn2 $ handler cb)
  where
    handler cb err entity = cb $
      case toMaybe entity of
        Just val -> lmap (error <<< show) $ read val
        Nothing ->
          case toMaybe err of
            Just msg -> Left msg
            Nothing -> Right Nothing

keyById :: Kind -> Int -> Key
keyById kind id =
  Key { kind: notNull kind, id: notNull $ show id, name: null, path: [], parent: null }

type CommitCallback = EffectFn2 (Nullable Error) CommitResponse Unit
type GetCallback = EffectFn2 (Nullable Error) (Nullable Foreign) Unit

foreign import _connect :: EffectFn1 ClientOptions Client
foreign import _createQuery :: Fn2 Client Kind Query
foreign import _delete :: EffectFn3 Client Key CommitCallback Unit
foreign import _save :: EffectFn3 Client (Payload Foreign) CommitCallback Unit
foreign import _get :: EffectFn4 Client Key QueryOptions GetCallback Unit
