port module Main exposing (..)

import Html as H exposing (Html)
import Html.Attributes as HA
import Json.Decode as Json exposing (Decoder)
import Process
import Task


main : Program Json.Value Model Msg
main =
    H.programWithFlags
        { init = initialState
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.batch [ attributes AttributesChange ]
        }


type alias Model =
    { count : Int
    , color : String
    }


initialState : Json.Value -> ( Model, Cmd Msg )
initialState attrs =
    ( { count = 0
      , color =
            attrs
                |> Json.decodeValue attributeDecoder
                |> Result.withDefault defaultAttributes
                |> .color
      }
    , waitAndUpdate
    )


type alias Attributes =
    { color : String }


defaultAttributes : Attributes
defaultAttributes =
    { color = "#0F0" }


type Msg
    = UpdateCounter
    | AttributesChange Attributes


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateCounter ->
            let
                newCount =
                    model.count + 1
            in
                { model | count = model.count + 1 }
                    ! [ waitAndUpdate
                      , events <| Events <| newCount
                      ]

        AttributesChange attributes ->
            { model | color = attributes.color } ! []


waitAndUpdate : Cmd Msg
waitAndUpdate =
    Process.sleep 1000
        |> Task.perform (always UpdateCounter)


type alias Events =
    { change : Int
    }


port events : Events -> Cmd msg


port attributes : (Attributes -> msg) -> Sub msg


view : Model -> Html Msg
view model =
    H.div [ HA.style [ ( "color", model.color ) ] ]
        [ H.text <| toString model ]


attributeDecoder : Decoder Attributes
attributeDecoder =
    Json.string
        |> Json.at [ "color" ]
        |> Json.map Attributes
