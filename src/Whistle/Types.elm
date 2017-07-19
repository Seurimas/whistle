module Whistle.Types exposing (..)


type alias Error =
    String


type alias NodeType =
    String


{-| Truly native value.
-}
type alias NodeRef =
    () -> ()


type alias RawNode =
    { nodeType : NodeType
    , nodeRef : NodeRef
    , destination : Bool
    , source : Bool
    }


type alias AudioNode =
    { source : RawNode
    , volume : RawNode
    }
