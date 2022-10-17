{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{- and then slightly modified -}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields where

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
import Proto.Opentelemetry.Proto.Common.V1.Common qualified
import Proto.Opentelemetry.Proto.Resource.V1.Resource qualified

attributes ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "attributes" a
  ) =>
  Lens.Family2.LensLike' f s a
attributes = Data.ProtoLens.Field.field @"attributes"

body ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "body" a) =>
  Lens.Family2.LensLike' f s a
body = Data.ProtoLens.Field.field @"body"

droppedAttributesCount ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "droppedAttributesCount" a
  ) =>
  Lens.Family2.LensLike' f s a
droppedAttributesCount =
  Data.ProtoLens.Field.field @"droppedAttributesCount"

flags ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "flags" a) =>
  Lens.Family2.LensLike' f s a
flags = Data.ProtoLens.Field.field @"flags"

logRecords ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "logRecords" a
  ) =>
  Lens.Family2.LensLike' f s a
logRecords = Data.ProtoLens.Field.field @"logRecords"

maybe'body ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'body" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'body = Data.ProtoLens.Field.field @"maybe'body"

maybe'resource ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'resource" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'resource = Data.ProtoLens.Field.field @"maybe'resource"

maybe'scope ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'scope" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'scope = Data.ProtoLens.Field.field @"maybe'scope"

observedTimeUnixNano ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "observedTimeUnixNano" a
  ) =>
  Lens.Family2.LensLike' f s a
observedTimeUnixNano =
  Data.ProtoLens.Field.field @"observedTimeUnixNano"

resource ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "resource" a
  ) =>
  Lens.Family2.LensLike' f s a
resource = Data.ProtoLens.Field.field @"resource"

resourceLogs ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "resourceLogs" a
  ) =>
  Lens.Family2.LensLike' f s a
resourceLogs = Data.ProtoLens.Field.field @"resourceLogs"

schemaUrl ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "schemaUrl" a
  ) =>
  Lens.Family2.LensLike' f s a
schemaUrl = Data.ProtoLens.Field.field @"schemaUrl"

scope ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "scope" a) =>
  Lens.Family2.LensLike' f s a
scope = Data.ProtoLens.Field.field @"scope"

scopeLogs ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "scopeLogs" a
  ) =>
  Lens.Family2.LensLike' f s a
scopeLogs = Data.ProtoLens.Field.field @"scopeLogs"

severityNumber ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "severityNumber" a
  ) =>
  Lens.Family2.LensLike' f s a
severityNumber = Data.ProtoLens.Field.field @"severityNumber"

severityText ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "severityText" a
  ) =>
  Lens.Family2.LensLike' f s a
severityText = Data.ProtoLens.Field.field @"severityText"

spanId ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "spanId" a) =>
  Lens.Family2.LensLike' f s a
spanId = Data.ProtoLens.Field.field @"spanId"

timeUnixNano ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "timeUnixNano" a
  ) =>
  Lens.Family2.LensLike' f s a
timeUnixNano = Data.ProtoLens.Field.field @"timeUnixNano"

traceId ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "traceId" a) =>
  Lens.Family2.LensLike' f s a
traceId = Data.ProtoLens.Field.field @"traceId"

vec'attributes ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'attributes" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'attributes = Data.ProtoLens.Field.field @"vec'attributes"

vec'logRecords ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'logRecords" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'logRecords = Data.ProtoLens.Field.field @"vec'logRecords"

vec'resourceLogs ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'resourceLogs" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'resourceLogs = Data.ProtoLens.Field.field @"vec'resourceLogs"

vec'scopeLogs ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'scopeLogs" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'scopeLogs = Data.ProtoLens.Field.field @"vec'scopeLogs"
