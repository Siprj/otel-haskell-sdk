{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{- and then slightly modified -}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService_Fields where

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
import Proto.Opentelemetry.Proto.Trace.V1.Trace qualified

errorMessage ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "errorMessage" a
  ) =>
  Lens.Family2.LensLike' f s a
errorMessage = Data.ProtoLens.Field.field @"errorMessage"

maybe'partialSuccess ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "maybe'partialSuccess" a
  ) =>
  Lens.Family2.LensLike' f s a
maybe'partialSuccess =
  Data.ProtoLens.Field.field @"maybe'partialSuccess"

partialSuccess ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "partialSuccess" a
  ) =>
  Lens.Family2.LensLike' f s a
partialSuccess = Data.ProtoLens.Field.field @"partialSuccess"

rejectedSpans ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "rejectedSpans" a
  ) =>
  Lens.Family2.LensLike' f s a
rejectedSpans = Data.ProtoLens.Field.field @"rejectedSpans"

resourceSpans ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "resourceSpans" a
  ) =>
  Lens.Family2.LensLike' f s a
resourceSpans = Data.ProtoLens.Field.field @"resourceSpans"

vec'resourceSpans ::
  forall f s a.
  ( Prelude.Functor f
  , Data.ProtoLens.Field.HasField s "vec'resourceSpans" a
  ) =>
  Lens.Family2.LensLike' f s a
vec'resourceSpans = Data.ProtoLens.Field.field @"vec'resourceSpans"
