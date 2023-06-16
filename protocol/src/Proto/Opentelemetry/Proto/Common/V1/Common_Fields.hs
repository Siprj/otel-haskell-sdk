{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{- and then slightly modified -}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Common.V1.Common_Fields where

import Data.ProtoLens.Runtime.Data.ByteString qualified as Data.ByteString
import Data.ProtoLens.Runtime.Data.ByteString.Char8 qualified as Data.ByteString.Char8
import Data.ProtoLens.Runtime.Data.Int qualified as Data.Int
import Data.ProtoLens.Runtime.Data.Map qualified as Data.Map
import Data.ProtoLens.Runtime.Data.Monoid qualified as Data.Monoid
import Data.ProtoLens.Runtime.Data.ProtoLens qualified as Data.ProtoLens
import Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Bytes qualified as Data.ProtoLens.Encoding.Bytes
import Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Growing qualified as Data.ProtoLens.Encoding.Growing
import Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Parser.Unsafe qualified as Data.ProtoLens.Encoding.Parser.Unsafe
import Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Wire qualified as Data.ProtoLens.Encoding.Wire
import Data.ProtoLens.Runtime.Data.ProtoLens.Field qualified as Data.ProtoLens.Field
import Data.ProtoLens.Runtime.Data.ProtoLens.Message.Enum qualified as Data.ProtoLens.Message.Enum
import Data.ProtoLens.Runtime.Data.ProtoLens.Service.Types qualified as Data.ProtoLens.Service.Types
import Data.ProtoLens.Runtime.Data.Text qualified as Data.Text
import Data.ProtoLens.Runtime.Data.Text.Encoding qualified as Data.Text.Encoding
import Data.ProtoLens.Runtime.Data.Vector qualified as Data.Vector
import Data.ProtoLens.Runtime.Data.Vector.Generic qualified as Data.Vector.Generic
import Data.ProtoLens.Runtime.Data.Vector.Unboxed qualified as Data.Vector.Unboxed
import Data.ProtoLens.Runtime.Data.Word qualified as Data.Word
import Data.ProtoLens.Runtime.Lens.Family2 qualified as Lens.Family2
import Data.ProtoLens.Runtime.Lens.Family2.Unchecked qualified as Lens.Family2.Unchecked
import Data.ProtoLens.Runtime.Prelude qualified as Prelude
import Data.ProtoLens.Runtime.Text.Read qualified as Text.Read

arrayValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "arrayValue" a
  ) =>
  Lens.Family2.LensLike' f s a
arrayValue = Data.ProtoLens.Field.field @"arrayValue"

attributes ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "attributes" a
  ) =>
  Lens.Family2.LensLike' f s a
attributes = Data.ProtoLens.Field.field @"attributes"

boolValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "boolValue" a
  ) =>
  Lens.Family2.LensLike' f s a
boolValue = Data.ProtoLens.Field.field @"boolValue"

bytesValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "bytesValue" a
  ) =>
  Lens.Family2.LensLike' f s a
bytesValue = Data.ProtoLens.Field.field @"bytesValue"

doubleValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "doubleValue" a
  ) =>
  Lens.Family2.LensLike' f s a
doubleValue = Data.ProtoLens.Field.field @"doubleValue"

droppedAttributesCount ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "droppedAttributesCount" a
  ) =>
  Lens.Family2.LensLike' f s a
droppedAttributesCount =
  Data.ProtoLens.Field.field @"droppedAttributesCount"

intValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "intValue" a
  ) =>
  Lens.Family2.LensLike' f s a
intValue = Data.ProtoLens.Field.field @"intValue"

key ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "key" a) =>
  Lens.Family2.LensLike' f s a
key = Data.ProtoLens.Field.field @"key"

kvlistValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "kvlistValue" a
  ) =>
  Lens.Family2.LensLike' f s a
kvlistValue = Data.ProtoLens.Field.field @"kvlistValue"

maybe'arrayValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'arrayValue" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'arrayValue = Data.ProtoLens.Field.field @"maybe'arrayValue"

maybe'boolValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'boolValue" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'boolValue = Data.ProtoLens.Field.field @"maybe'boolValue"

maybe'bytesValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'bytesValue" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'bytesValue = Data.ProtoLens.Field.field @"maybe'bytesValue"

maybe'doubleValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'doubleValue" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'doubleValue = Data.ProtoLens.Field.field @"maybe'doubleValue"

maybe'intValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'intValue" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'intValue = Data.ProtoLens.Field.field @"maybe'intValue"

maybe'kvlistValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'kvlistValue" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'kvlistValue = Data.ProtoLens.Field.field @"maybe'kvlistValue"

maybe'stringValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'stringValue" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'stringValue = Data.ProtoLens.Field.field @"maybe'stringValue"

maybe'value ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'value" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'value = Data.ProtoLens.Field.field @"maybe'value"

name ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "name" a) =>
  Lens.Family2.LensLike' f s a
name = Data.ProtoLens.Field.field @"name"

stringValue ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "stringValue" a
  ) =>
  Lens.Family2.LensLike' f s a
stringValue = Data.ProtoLens.Field.field @"stringValue"

value ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "value" a) =>
  Lens.Family2.LensLike' f s a
value = Data.ProtoLens.Field.field @"value"

values ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "values" a) =>
  Lens.Family2.LensLike' f s a
values = Data.ProtoLens.Field.field @"values"

vec'attributes ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'attributes" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'attributes = Data.ProtoLens.Field.field @"vec'attributes"

vec'values ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'values" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'values = Data.ProtoLens.Field.field @"vec'values"

version ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "version" a) =>
  Lens.Family2.LensLike' f s a
version = Data.ProtoLens.Field.field @"version"
