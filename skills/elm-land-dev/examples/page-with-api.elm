module Pages.Users exposing (Model, Msg, page)

{-| Example: A page that fetches and displays a list of users from an API.

URL: /users

-}

import Api.Users
import Effect exposing (Effect)
import Html
import Html.Attributes
import Http
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type Model
    = Loading
    | Success (List Api.Users.User)
    | Failure Http.Error


init : () -> ( Model, Effect Msg )
init _ =
    ( Loading
    , Api.Users.getAll { onResponse = ApiResponded }
        |> Effect.sendCmd
    )



-- UPDATE


type Msg
    = ApiResponded (Result Http.Error (List Api.Users.User))
    | RetryClicked


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ApiResponded (Ok users) ->
            ( Success users, Effect.none )

        ApiResponded (Err error) ->
            ( Failure error, Effect.none )

        RetryClicked ->
            ( Loading
            , Api.Users.getAll { onResponse = ApiResponded }
                |> Effect.sendCmd
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Users"
    , body =
        [ Html.h1 [] [ Html.text "Users" ]
        , case model of
            Loading ->
                Html.p [] [ Html.text "Loading users..." ]

            Success users ->
                Html.ul []
                    (List.map viewUser users)

            Failure _ ->
                Html.div []
                    [ Html.p [] [ Html.text "Could not load users." ]
                    , Html.button [ Html.Events.onClick RetryClicked ]
                        [ Html.text "Retry" ]
                    ]
        ]
    }


viewUser : Api.Users.User -> Html.Html Msg
viewUser user =
    Html.li []
        [ Html.a
            [ Route.Path.href (Route.Path.Users_Id_ { id = user.id }) ]
            [ Html.text user.name ]
        ]
