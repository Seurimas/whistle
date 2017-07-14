module Whistle exposing (..)

import Whistle.Native exposing (..)
import Whistle.Types exposing (..)
import Platform exposing (Task)
import Task


changeVolume : Float -> Task Error AudioNode -> Task Error AudioNode
changeVolume newVolume init =
    let
        cv ({ volume } as audioNode) =
            changeGain volume newVolume
                |> Task.map (\_ -> audioNode)
    in
        init
            |> Task.andThen cv


defaultOutput : Task Error AudioNode -> Task Error AudioNode
defaultOutput init =
    let
        do ({ volume } as audioNode) =
            connect volume audioContextDestination
                |> Task.map (\_ -> Debug.log "Output" audioNode)
    in
        init
            |> Task.andThen do


audioNode : Task Error RawNode -> Task Error AudioNode
audioNode source =
    source
        |> Task.andThen
            (\sourceNode ->
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
