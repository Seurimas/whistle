module Main exposing (..)

import Whistle
import Whistle.Types
import Whistle.Native
import Html exposing (Html, input)
import Html.Attributes exposing (type_, value, min, max)
import Html.Events exposing (onInput)
import Platform.Sub
import Task exposing (perform, attempt)


type alias Model =
    { volume : Int
    , audioNode : Maybe Whistle.Types.AudioNode
    }


type Msg
    = Init Whistle.Types.AudioNode
    | VolumeChange Int
    | Noop


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
        Init audioNode ->
            { model | audioNode = Just audioNode } ! []

        VolumeChange newVolume ->
            case model.audioNode of
                Just audioNode ->
                    { model | volume = newVolume }
                        ! [ attempt justReportError (Whistle.changeVolume ((toFloat newVolume) / 100) audioNode) ]

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
            , audioNode = Nothing
            }
                ! [ attempt (doButReport Init)
                        (Whistle.Native.createOscillator "sine" 440
                            |> Task.andThen Whistle.makeAudioNode
                            |> Task.andThen Whistle.pipeToDefaultOutput
                        )
                  ]
        , subscriptions = subs
        , update = update
        , view = render
        }
