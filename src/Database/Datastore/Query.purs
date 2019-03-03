module Database.Datastore.Query where
import Effect.Uncurried

import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn2, Fn3, Fn4, runFn2, runFn3, runFn4)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toMaybe)
import Data.Traversable (traverse)
import Database.Datastore.Types (FilterOperator, Key, Property, Query, QueryInfo)
import Effect.Aff (Aff, Error, error, makeAff, nonCanceler)
import Foreign (Foreign)
import Prelude (Unit, show, ($), (<$), (<<<))
import Simple.JSON (class ReadForeign, class WriteForeign, read, write)
import Unsafe.Coerce (unsafeCoerce)

lt :: FilterOperator
lt = unsafeCoerce "<"

lte :: FilterOperator
lte = unsafeCoerce "<="

eq :: FilterOperator
eq = unsafeCoerce "="

gt :: FilterOperator
gt = unsafeCoerce ">"

gte :: FilterOperator
gte = unsafeCoerce ">="

filter :: ∀ a. WriteForeign a => Property -> FilterOperator -> a -> Query -> Query
filter p op v = runFn4 _filter p op (write v)

hasAncestor :: Key -> Query -> Query
hasAncestor = runFn2 _hasAncestor

order :: Property -> { descending :: Boolean } -> Query -> Query
order = runFn3 _order

groupBy :: Array Property -> Query -> Query
groupBy = runFn2 _groupBy

select :: Array Property -> Query -> Query
select = runFn2 _select

limit :: Int -> Query -> Query
limit = runFn2 _limit

offset :: Int -> Query -> Query
offset = runFn2 _offset

run :: ∀ a. ReadForeign a => Query -> Aff (Array a)
run q = makeAff \cb -> nonCanceler <$ runEffectFn2 _run q (mkEffectFn3 $ handler cb)
  where
    handler cb err entities _ = cb $
      case toMaybe entities of 
        Just e -> lmap (error <<< show) $ traverse read e
        Nothing -> Left err

type QueryCallback = EffectFn3 Error (Nullable (Array Foreign)) QueryInfo Unit

foreign import _filter :: Fn4 Property FilterOperator Foreign Query Query
foreign import _hasAncestor :: Fn2 Key Query Query
foreign import _order :: Fn3 Property { descending :: Boolean } Query Query
foreign import _groupBy :: Fn2 (Array Property) Query Query
foreign import _select :: Fn2 (Array Property) Query Query
foreign import _limit :: Fn2 Int Query Query
foreign import _offset :: Fn2 Int Query Query
foreign import _run :: EffectFn2 Query QueryCallback Unit
