module Whistle.Types exposing (..)


type alias Error =
    String


type alias NodeType =
    String


{-| Native buffer value (e.g. sound files).
Different types to help the type system.
-}
type alias Buffer =
    () -> Int


{-| Native audio node value (e.g. sound node, volume node, etc.).
Different types to help the type system.
-}
type alias NodeRef =
    () -> String


type alias RawNode =
    { nodeType : NodeType
    , realNode : NodeRef
    , destination : Bool
    , source : Bool
    }
