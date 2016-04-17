module Main (..) where

import Task exposing (Task)
import Json.Decode as Decode exposing (Value)
import Effects exposing (Effects, Never)
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import StartApp exposing (App)


type alias Attributes =
  { color : String
  }


defaultAttributes : Attributes
defaultAttributes =
  { color = "#0F0"
  }


type alias Model =
  { count : Int
  , color : String
  }


initialState : ( Model, Effects Action )
initialState =
  ( { count = 0
    , color = defaultAttributes.color
    }
  , waitAndUpdate
  )


decodeAttributes : Decode.Decoder Attributes
decodeAttributes =
  Decode.map
    Attributes
    (Decode.at [ "color" ] Decode.string)


type alias Events =
  { change : Int
  }


type Action
  = UpdateCounter
  | AttributesChange Attributes


waitAndUpdate : Effects Action
waitAndUpdate =
  Task.sleep 1000
    |> Task.map (always UpdateCounter)
    |> Effects.task


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    UpdateCounter ->
      ( { model | count = model.count + 1 }
      , waitAndUpdate
      )

    AttributesChange attributes ->
      ( { model | color = attributes.color }
      , Effects.none
      )


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ style [ ( "color", model.color ) ] ]
    [ text <| toString model ]


app : App Model
app =
  StartApp.start
    { init = initialState
    , update = update
    , view = view
    , inputs = [ attributesInput ]
    }


port tasks : Signal (Task Never ())
port tasks =
  app.tasks


main : Signal Html
main =
  app.html


port events : Signal Events
port events =
  app.model
    |> Signal.dropRepeats
    |> Signal.map (\model -> { change = model.count })


port attributes : Signal Value
attributesInput : Signal Action
attributesInput =
  attributes
    |> Signal.map (Decode.decodeValue decodeAttributes)
    |> Signal.filterMap Result.toMaybe defaultAttributes
    |> Signal.map AttributesChange
