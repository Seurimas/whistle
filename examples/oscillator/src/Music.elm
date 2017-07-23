module Main exposing (..)

import Whistle
import Whistle.Types
import Whistle.Native
import Http
import Html exposing (Html, input)
import Html.Attributes exposing (type_, value, min, max)
import Html.Events exposing (onInput)
import Platform.Sub
import Task exposing (perform, attempt)


type alias Model =
    { volume : Int
    , gainNode : Maybe Whistle.Types.RawNode
    }


type Msg
    = Buffer String
    | Init Whistle.Types.RawNode
    | VolumeChange Int
    | Noop


receiveBuffer : Result Http.Error String -> Msg
receiveBuffer result =
    case result of
        Ok buffer ->
            Buffer buffer

        _ ->
            Noop


volumeChange input =
    case (String.toInt input) of
        Ok newVolume ->
            VolumeChange newVolume

        _ ->
            Noop


subs model =
    Platform.Sub.none


noop =
    Result.map (\_ -> Noop) >> Result.withDefault Noop


reportError =
    Result.mapError (Debug.log "Error: ")


doButReport do =
    Result.map do >> Result.withDefault Noop


justReportError =
    reportError >> noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init gainNode ->
            { model | gainNode = Just gainNode } ! []

        VolumeChange newVolume ->
            case model.gainNode of
                Just gainNode ->
                    { model | volume = newVolume }
                        ! [ attempt justReportError (Whistle.Native.changeGain ((toFloat newVolume) / 100) gainNode) ]

                Nothing ->
                    model ! []

        _ ->
            model ! []


render model =
    input
        [ type_ "range"
        , value (toString (Debug.log "Value" model.volume))
        , Html.Attributes.min "0"
        , Html.Attributes.max "100"
        , onInput volumeChange
        ]
        []


main : Program Never Model Msg
main =
    Html.program
        { init =
            { volume = 0
            , gainNode = Nothing
            }
                ! [ attempt (doButReport Init)
                        (Task.sequence
                            [ Whistle.Native.getAudioData "main_theme.mp3"
                                |> Task.andThen (Whistle.Native.createBufferSource True)
                                |> Task.andThen (Whistle.Native.startBufferSource 0)
                            , Whistle.Native.createGainNode 0
                            ]
                            |> Task.andThen Whistle.linkNodes
                            |> Task.andThen Whistle.linkToOutput
                        )
                  ]
        , subscriptions = subs
        , update = update
        , view = render
        }
