import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (int,string,at)
import RemoteData as RD exposing (WebData)
import Random

main : Program Never Model Msg
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
  , getRandomTip
  )



-- UPDATE
getRandomTip : Cmd Msg
getRandomTip =
  Random.generate GetTip (Random.int 1 5)

type Msg =
  NoOp
  | GetTip Int
  | TipResponse (WebData Tip)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
    GetTip num->
      (model, getTip num)
    TipResponse tip ->
      {model | tip = tip} ! []




-- VIEW

stylesheet : Html Msg
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


awesomeTip : WebData Tip -> Html Msg
awesomeTip tipWebdata =
  let
    tipElement : String -> String -> Html Msg
    tipElement author text_ =
        div [
          class "wrapper"
        ] [
          div [ class "awesomeTip-wrapper"]
            [
                div  [ class "autor"] [ text author]
               ,div [ class "tip-box"] [ text text_]
          ]
        ]
  in
    case tipWebdata of
      RD.Success tip ->
        tipElement tip.author tip.text

      RD.Failure e ->
        tipElement ":C" ("Error: " ++ toString e)

      RD.NotAsked ->
        tipElement "..." "Initialising..."

      RD.Loading ->
        tipElement "Loading..." "Loading..."


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


getTip : Int -> Cmd Msg
getTip id_ =
  let
    url = "http://localhost:3000/tips/" ++ (toString id_)
  in
    Http.get url decodeTip
        |> RD.sendRequest
        |> Cmd.map TipResponse
