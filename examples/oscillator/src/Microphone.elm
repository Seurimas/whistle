module Main exposing (..)

import Whistle
import Whistle.Native
import Html
import Platform.Sub
import Task exposing (perform, attempt)


type Msg
    = Noop


subs model =
    Platform.Sub.none


reportError =
    Result.mapError (Debug.log "Error: ") >> Result.map (\_ -> Noop) >> Result.withDefault Noop


update : Msg -> Int -> ( Int, Cmd Msg )
update msg model =
    case msg of
        _ ->
            model ! []


render model =
    Html.text ""


main : Program Never Int Msg
main =
    Html.program
        { init =
            0
                ! [ attempt reportError
                        (Task.sequence
                            [ Whistle.Native.getMicrophoneStream
                            , Task.succeed Whistle.Native.audioContextDestination
                            ]
                            |> Task.andThen Whistle.linkNodes
                        )
                  ]
        , subscriptions = subs
        , update = update
        , view = render
        }
