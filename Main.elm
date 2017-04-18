import Html exposing (..)

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = (\c -> Sub.none)
    }

-- model
type alias Model = {
  text: String
}

init : (Model, Cmd Msg)
init = (Model "hej", Cmd.none)

type Msg = NoOp

-- update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)


-- view

view model =
  div [] [ text model.text]
