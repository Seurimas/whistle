module Whistle.Native exposing (..)

import Whistle.Types exposing (..)
import Platform exposing (Task)
import Native.Impl


audioContextDestination : RawNode
audioContextDestination =
    Native.Impl.audioContextDestination


createAnalyzer : Task x Analyzer
createAnalyzer =
    Native.Impl.createAnalyzer


destroyAnalyzer : Analyzer -> Task Error Analyzer
destroyAnalyzer =
    Native.Impl.destroyAnalyzer


createOscillator : String -> Float -> Task x RawNode
createOscillator =
    Native.Impl.createOscillator


createGainNode : Float -> Task x RawNode
createGainNode =
    Native.Impl.createGainNode


changeGain : RawNode -> Float -> Task Error RawNode
changeGain =
    Native.Impl.changeGain


getMicrophoneStream : Task Error RawNode
getMicrophoneStream =
    Native.Impl.getMicrophoneStream


connect : RawNode -> RawNode -> Task Error RawNode
connect =
    Native.Impl.connect
