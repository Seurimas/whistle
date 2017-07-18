module Whistle.Types exposing (..)


type alias Error =
    String


type alias NodeType =
    String


type alias NodeRef =
    Int


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
