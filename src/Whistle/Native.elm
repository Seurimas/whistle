module Whistle.Native exposing (..)

{-|
# Input/Output
@docs audioContextDestination, getMicrophoneStream
# Buffers/Files
@docs getAudioData, createBufferSource, startSource, startSourceNow, stopSource
# Oscillators (single notes)
@docs createOscillator
# Gains (volume)
@docs createGainNode, changeGain
# Bringing it all together.
@docs connect
-}

import Whistle.Types exposing (..)
import Platform exposing (Task)
import Native.Impl


{-| Speaker output.
-}
audioContextDestination : RawNode
audioContextDestination =
    Native.Impl.audioContextDestination


{-| Retrieves an audio buffer from a URL.
-}
getAudioData : String -> Task x Buffer
getAudioData =
    Native.Impl.getAudioData


{-| Creates a buffer source node (i.e. a sound effect, or music) from a buffer
-}
createBufferSource : Bool -> Buffer -> Task x RawNode
createBufferSource =
    Native.Impl.createBufferSource


{-| Plays a buffer node at a specific time. May be used multiple times.
-}
startSource : Float -> RawNode -> Task x RawNode
startSource =
    Native.Impl.startSource


{-| Plays a buffer node immediately. May be used multiple times.
-}
startSourceNow : RawNode -> Task x RawNode
startSourceNow =
    startSource 0


{-| Stops a buffer node.
-}
stopSource : RawNode -> Task x RawNode
stopSource =
    Native.Impl.stopSource


{-| Creates an oscillator node of a specific type and frequency. See https://developer.mozilla.org/en-US/docs/Web/API/OscillatorNode for types and frequencies.
-}
createOscillator : String -> Float -> Task x RawNode
createOscillator =
    Native.Impl.createOscillator


{-| Creates a gain (volume) node with a starting volume (0 to 1).
-}
createGainNode : Float -> Task x RawNode
createGainNode =
    Native.Impl.createGainNode


{-| Changes the gain (volume) of a gain node.
-}
changeGain : Float -> RawNode -> Task Error RawNode
changeGain =
    Native.Impl.changeGain


{-| Requests microphone access from the user and returns it as a Stream.
-}
getMicrophoneStream : Task Error RawNode
getMicrophoneStream =
    Native.Impl.getMicrophoneStream


{-| Connects a source node (e.g. buffers, oscillators, gains, mic streams) to a destination node (e.g. gains, AudioContext destination)
-}
connect : RawNode -> RawNode -> Task Error RawNode
connect =
    Native.Impl.connect
