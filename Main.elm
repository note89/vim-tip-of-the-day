-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (int,string,at)
import RemoteData as RD exposing (WebData)


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL

type alias Tip =
  { id: Int
  , text: String
  , author: String
  }

type alias Model =
  { tip: WebData Tip
  }


init : (Model, Cmd Msg)
init =
  ( {tip = RD.NotAsked}
  , getTip
  )



-- UPDATE


type Msg =
  NoOp
  | GetTip
  | TipResponse (WebData Tip)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
    GetTip ->
      (model, getTip)
    TipResponse tip ->
      {model | tip = tip} ! []




-- VIEW

stylesheet =
    let
        tag = "link"
        attrs =
            [ attribute "rel"       "stylesheet"
            , attribute "property"  "stylesheet"
            , attribute "href"      "/mystyle.css"
            ]
        children = []
    in
        node tag attrs children


awesomeTip tipWebdata =
  case tipWebdata of
    RD.Success tip ->
      div [
        class "wrapper"
      ] [
        div [ class "awesomeTip-wrapper"]
          [
              div  [ class "autor"] [ text tip.author]
              ,div [ class "tip-box"] [ text tip.text]
        ]
      ]

    _ ->
      div [] [ text "loading..."]


view : Model -> Html Msg
view model =
  div []
    [ stylesheet
    , h1 [id "header"] [ text "Vim tip of the day"]
    , awesomeTip model.tip
    ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- HTTP
decodeTip : Decode.Decoder Tip
decodeTip =
  Decode.map3 Tip
      (at ["id"] int)
      (at ["text"] string)
      (at ["author"] string)

getTip : Cmd Msg
getTip =
    Http.get "http://localhost:3000/tips/1" decodeTip
        |> RD.sendRequest
        |> Cmd.map TipResponse
