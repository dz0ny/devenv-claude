module Pages.Dashboard exposing (Model, Msg, page)

{-| Example: An auth-protected page with a sidebar layout.

URL: /dashboard
Requires: Authenticated user (Auth.User as first param)

-}

import Auth
import Effect exposing (Effect)
import Html
import Html.Attributes
import Html.Events
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init user
        , update = update
        , view = view user
        , subscriptions = subscriptions
        }
        |> Page.withLayout (toLayout user)


toLayout : Auth.User -> Model -> Layouts.Layout Msg
toLayout user _ =
    Layouts.Sidebar
        { title = "Dashboard"
        , user = user
        }



-- MODEL


type alias Model =
    { greeting : String
    }


init : Auth.User -> () -> ( Model, Effect Msg )
init user _ =
    ( { greeting = "Welcome back, " ++ user.name ++ "!" }
    , Effect.none
    )



-- UPDATE


type Msg
    = SignOutClicked


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SignOutClicked ->
            ( model
            , Shared.Msg.SignOut
                |> Effect.sendSharedMsg
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Auth.User -> Model -> View Msg
view user model =
    { title = "Dashboard"
    , body =
        [ Html.h1 [] [ Html.text model.greeting ]
        , Html.p []
            [ Html.text ("Signed in as " ++ user.name) ]
        , Html.button
            [ Html.Events.onClick SignOutClicked ]
            [ Html.text "Sign out" ]
        ]
    }
