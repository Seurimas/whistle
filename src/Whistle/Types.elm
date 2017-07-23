module Whistle.Types exposing (..)

{-| Types used in Whistle.
@docs Error, NodeType, Buffer, NodeRef, RawNode
-}


{-| Errors from native tasks.
-}
type alias Error =
    String


{-| The type of a given node. Usually .nodeType of a RawNode.
-}
type alias NodeType =
    String


{-| Native buffer value (e.g. sound files).
Different types to help the type system.
This is a function to sneak WebAudio primitives through customs.
Sometimes, the Elm customs seems to get confused by native objects and loop endlessly.
-}
type alias Buffer =
    () -> Int


{-| Native audio node value (e.g. sound node, volume node, etc.).
Different types to help the type system.
This is a function to sneak WebAudio primitives through customs.
Sometimes, the Elm customs seems to get confused by native objects and loop endlessly.
-}
type alias NodeRef =
    () -> String


{-| A node in WebAudio, with additional information.
-}
type alias RawNode =
    { nodeType : NodeType
    , realNode : NodeRef
    , destination : Bool
    , source : Bool
    }
