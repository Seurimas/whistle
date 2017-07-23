module Whistle exposing (..)

{-| Helper methods. Use `Whistle.Native` for most things and this to package it up nicely.
# Linking
@docs linkToOutput, linkNodes
-}

import Whistle.Native exposing (..)
import Whistle.Types exposing (..)
import Platform exposing (Task)
import Task


{-| Helper method to connect a node to the speakers. Returns the node used, not the speakers.
-}
linkToOutput : RawNode -> Task Error RawNode
linkToOutput audioNode =
    Whistle.Native.connect audioNode Whistle.Native.audioContextDestination
        |> Task.map (\_ -> audioNode)


{-| Links a series of nodes sequentially. Good for initializing a complicated audio chain.
-}
linkNodes : List RawNode -> Task Error RawNode
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
                    Task.succeed final

                _ :: rest ->
                    ultimateNode rest

                [] ->
                    Task.fail "Empty list given to linkNodes"
    in
        Task.sequence connectTasks
            |> Task.andThen ultimateNode
