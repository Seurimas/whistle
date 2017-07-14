module Whistle.Types exposing (..)


type alias Error =
    String


type alias RawNode =
    ( String, Int )


type alias Analyzer =
    Int


type alias AudioNode =
    { source : RawNode
    , volume : RawNode
    }
