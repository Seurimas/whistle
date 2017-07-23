module Whistle.Native exposing (..)

import Whistle.Types exposing (..)
import Platform exposing (Task)
import Native.Impl


audioContextDestination : RawNode
audioContextDestination =
    Native.Impl.audioContextDestination


getAudioData : String -> Task x Buffer
getAudioData =
    Native.Impl.getAudioData


createBufferSource : Bool -> Buffer -> Task x RawNode
createBufferSource =
    Native.Impl.createBufferSource


startSource : Float -> RawNode -> Task x RawNode
startSource =
    Native.Impl.startSource


startSourceNow : RawNode -> Task x RawNode
startSourceNow =
    startSource 0


stopSource : RawNode -> Task x RawNode
stopSource =
    Native.Impl.stopSource


createOscillator : String -> Float -> Task x RawNode
createOscillator =
    Native.Impl.createOscillator


createGainNode : Float -> Task x RawNode
createGainNode =
    Native.Impl.createGainNode


changeGain : Float -> RawNode -> Task Error RawNode
changeGain =
    Native.Impl.changeGain


getMicrophoneStream : Task Error RawNode
getMicrophoneStream =
    Native.Impl.getMicrophoneStream


connect : RawNode -> RawNode -> Task Error RawNode
connect =
    Native.Impl.connect
