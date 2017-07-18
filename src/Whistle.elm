module Whistle exposing (..)

import Whistle.Native exposing (..)
import Whistle.Types exposing (..)
import Platform exposing (Task)
import Task


changeVolume : Float -> AudioNode -> Task Error AudioNode
changeVolume newVolume ({ volume } as audioNode) =
    changeGain newVolume volume
        |> Task.map (\_ -> audioNode)


pipeToDefaultOutput : AudioNode -> Task Error AudioNode
pipeToDefaultOutput ({ volume } as audioNode) =
    connect volume audioContextDestination
        |> Task.map (\_ -> audioNode)


makeAudioNode : RawNode -> Task Error AudioNode
makeAudioNode sourceNode =
    createGainNode 1
        |> Task.andThen
            (\gainNode ->
                connect sourceNode gainNode
                    |> Task.map
                        (\_ ->
                            { source = sourceNode
                            , volume = gainNode
                            }
                        )
            )


linkNodes : List RawNode -> Task Error (Maybe RawNode)
linkNodes audioNodes =
    let
        nodePairs xs ys =
            case ( xs, ys ) of
                ( x :: xTail, y :: yTail ) ->
                    ( x, y ) :: nodePairs xTail yTail

                ( _, _ ) ->
                    []

        connectedPairs =
            case ( audioNodes, audioNodes ) of
                ( first, _ :: second ) ->
                    nodePairs first second

                ( _, _ ) ->
                    []

        connectTasks =
            connectedPairs
                |> List.map (\( first, second ) -> connect first second)

        ultimateNode nodes =
            case nodes of
                final :: [] ->
                    Just final

                _ :: rest ->
                    ultimateNode rest

                [] ->
                    Nothing
    in
        Task.sequence connectTasks
            |> Task.map ultimateNode
