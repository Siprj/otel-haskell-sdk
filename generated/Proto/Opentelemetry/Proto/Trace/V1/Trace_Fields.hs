{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{- and then slightly modified -}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields where

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

code ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "code" a) =>
  Lens.Family2.LensLike' f s a
code = Data.ProtoLens.Field.field @"code"

droppedAttributesCount ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "droppedAttributesCount" a
  ) =>
  Lens.Family2.LensLike' f s a
droppedAttributesCount =
  Data.ProtoLens.Field.field @"droppedAttributesCount"

droppedEventsCount ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "droppedEventsCount" a
  ) =>
  Lens.Family2.LensLike' f s a
droppedEventsCount =
  Data.ProtoLens.Field.field @"droppedEventsCount"

droppedLinksCount ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "droppedLinksCount" a
  ) =>
  Lens.Family2.LensLike' f s a
droppedLinksCount = Data.ProtoLens.Field.field @"droppedLinksCount"

endTimeUnixNano ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "endTimeUnixNano" a
  ) =>
  Lens.Family2.LensLike' f s a
endTimeUnixNano = Data.ProtoLens.Field.field @"endTimeUnixNano"

events ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "events" a) =>
  Lens.Family2.LensLike' f s a
events = Data.ProtoLens.Field.field @"events"

kind ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "kind" a) =>
  Lens.Family2.LensLike' f s a
kind = Data.ProtoLens.Field.field @"kind"

links ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "links" a) =>
  Lens.Family2.LensLike' f s a
links = Data.ProtoLens.Field.field @"links"

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

maybe'status ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'status" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'status = Data.ProtoLens.Field.field @"maybe'status"

message ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "message" a) =>
  Lens.Family2.LensLike' f s a
message = Data.ProtoLens.Field.field @"message"

name ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "name" a) =>
  Lens.Family2.LensLike' f s a
name = Data.ProtoLens.Field.field @"name"

parentSpanId ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "parentSpanId" a
  ) =>
  Lens.Family2.LensLike' f s a
parentSpanId = Data.ProtoLens.Field.field @"parentSpanId"

resource ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "resource" a
  ) =>
  Lens.Family2.LensLike' f s a
resource = Data.ProtoLens.Field.field @"resource"

resourceSpans ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "resourceSpans" a
  ) =>
  Lens.Family2.LensLike' f s a
resourceSpans = Data.ProtoLens.Field.field @"resourceSpans"

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

scopeSpans ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "scopeSpans" a
  ) =>
  Lens.Family2.LensLike' f s a
scopeSpans = Data.ProtoLens.Field.field @"scopeSpans"

spanId ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "spanId" a) =>
  Lens.Family2.LensLike' f s a
spanId = Data.ProtoLens.Field.field @"spanId"

spans ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "spans" a) =>
  Lens.Family2.LensLike' f s a
spans = Data.ProtoLens.Field.field @"spans"

startTimeUnixNano ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "startTimeUnixNano" a
  ) =>
  Lens.Family2.LensLike' f s a
startTimeUnixNano = Data.ProtoLens.Field.field @"startTimeUnixNano"

status ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "status" a) =>
  Lens.Family2.LensLike' f s a
status = Data.ProtoLens.Field.field @"status"

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

traceState ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "traceState" a
  ) =>
  Lens.Family2.LensLike' f s a
traceState = Data.ProtoLens.Field.field @"traceState"

vec'attributes ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'attributes" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'attributes = Data.ProtoLens.Field.field @"vec'attributes"

vec'events ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'events" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'events = Data.ProtoLens.Field.field @"vec'events"

vec'links ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'links" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'links = Data.ProtoLens.Field.field @"vec'links"

vec'resourceSpans ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'resourceSpans" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'resourceSpans = Data.ProtoLens.Field.field @"vec'resourceSpans"

vec'scopeSpans ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'scopeSpans" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'scopeSpans = Data.ProtoLens.Field.field @"vec'scopeSpans"

vec'spans ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'spans" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'spans = Data.ProtoLens.Field.field @"vec'spans"
