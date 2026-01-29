# Common Elm Land Operations

## Navigation

### Link to a page

```elm
import Route.Path

Html.a
    [ Route.Path.href Route.Path.Settings ]
    [ Html.text "Settings" ]
```

### Programmatic navigation

```elm
Effect.pushRoute
    { path = Route.Path.Users_Id_ { id = "42" }
    , query = Dict.fromList [ ( "tab", "profile" ) ]
    , hash = Nothing
    }
```

### Replace route (no history entry)

```elm
Effect.replaceRoute
    { path = Route.Path.Home_
    , query = Dict.empty
    , hash = Nothing
    }
```

### External URL

```elm
Effect.loadExternalUrl "https://example.com"
```

### Access route parameters

```elm
-- Dynamic segment: src/Pages/Users/Id_.elm
page : { id : String } -> Shared.Model -> Route () -> Page Model Msg
page params shared route =
    -- params.id contains the URL segment value
    -- route.query is Dict String String for query params
    -- route.hash is Maybe String
    -- route.url.path is the full path string
```

## API Calls (HTTP)

### Install dependencies

```sh
npx elm install elm/http
npx elm install elm/json
```

### Define an API module

```elm
module Api.Users exposing (User, getAll, getOne)

import Http
import Json.Decode as Decode

type alias User =
    { id : String
    , name : String
    , email : String
    }

getAll : { onResponse : Result Http.Error (List User) -> msg } -> Cmd msg
getAll options =
    Http.get
        { url = "/api/users"
        , expect = Http.expectJson options.onResponse (Decode.list decoder)
        }

getOne : { id : String, onResponse : Result Http.Error User -> msg } -> Cmd msg
getOne options =
    Http.get
        { url = "/api/users/" ++ options.id
        , expect = Http.expectJson options.onResponse decoder
        }

decoder : Decode.Decoder User
decoder =
    Decode.map3 User
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "email" Decode.string)
```

### POST with JSON body

```elm
import Http
import Json.Encode as Encode

createUser : { name : String, email : String, onResponse : Result Http.Error User -> msg } -> Cmd msg
createUser options =
    Http.post
        { url = "/api/users"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "name", Encode.string options.name )
                    , ( "email", Encode.string options.email )
                    ]
                )
        , expect = Http.expectJson options.onResponse decoder
        }
```

### Use in a page

```elm
type Model
    = Loading
    | Success (List Api.Users.User)
    | Failure Http.Error

type Msg
    = ApiResponded (Result Http.Error (List Api.Users.User))

init : () -> ( Model, Effect Msg )
init _ =
    ( Loading
    , Api.Users.getAll { onResponse = ApiResponded }
        |> Effect.sendCmd
    )

update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ApiResponded (Ok users) ->
            ( Success users, Effect.none )

        ApiResponded (Err httpError) ->
            ( Failure httpError, Effect.none )

view : Model -> View Msg
view model =
    { title = "Users"
    , body =
        [ case model of
            Loading ->
                Html.text "Loading..."

            Success users ->
                Html.ul []
                    (List.map (\u -> Html.li [] [ Html.text u.name ]) users)

            Failure _ ->
                Html.text "Failed to load users."
        ]
    }
```

### HTTP request with auth token

```elm
import Http

getProtected :
    { token : String
    , onResponse : Result Http.Error a -> msg
    , decoder : Decode.Decoder a
    , url : String
    }
    -> Cmd msg
getProtected options =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ options.token) ]
        , url = options.url
        , body = Http.emptyBody
        , expect = Http.expectJson options.onResponse options.decoder
        , timeout = Nothing
        , tracker = Nothing
        }
```

## Forms

### Form model pattern

```elm
type alias Model =
    { name : String
    , email : String
    , isSubmitting : Bool
    , errors : List String
    }

init : () -> ( Model, Effect Msg )
init _ =
    ( { name = ""
      , email = ""
      , isSubmitting = False
      , errors = []
      }
    , Effect.none
    )
```

### Form messages and update

```elm
type Msg
    = NameChanged String
    | EmailChanged String
    | FormSubmitted
    | ApiResponded (Result Http.Error Api.Users.User)

update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NameChanged name ->
            ( { model | name = name }, Effect.none )

        EmailChanged email ->
            ( { model | email = email }, Effect.none )

        FormSubmitted ->
            ( { model | isSubmitting = True, errors = [] }
            , Api.Users.createUser
                { name = model.name
                , email = model.email
                , onResponse = ApiResponded
                }
                |> Effect.sendCmd
            )

        ApiResponded (Ok _) ->
            ( model
            , Effect.pushRoute
                { path = Route.Path.Home_
                , query = Dict.empty
                , hash = Nothing
                }
            )

        ApiResponded (Err _) ->
            ( { model | isSubmitting = False, errors = [ "Something went wrong" ] }
            , Effect.none
            )
```

### Form view

```elm
view : Model -> View Msg
view model =
    { title = "Create User"
    , body =
        [ Html.form [ Html.Events.onSubmit FormSubmitted ]
            [ Html.label []
                [ Html.text "Name"
                , Html.input
                    [ Html.Attributes.type_ "text"
                    , Html.Attributes.value model.name
                    , Html.Events.onInput NameChanged
                    ]
                    []
                ]
            , Html.label []
                [ Html.text "Email"
                , Html.input
                    [ Html.Attributes.type_ "email"
                    , Html.Attributes.value model.email
                    , Html.Events.onInput EmailChanged
                    ]
                    []
                ]
            , Html.button
                [ Html.Attributes.disabled model.isSubmitting ]
                [ Html.text
                    (if model.isSubmitting then
                        "Saving..."
                     else
                        "Create"
                    )
                ]
            , if List.isEmpty model.errors then
                Html.text ""
              else
                Html.ul []
                    (List.map (\e -> Html.li [] [ Html.text e ]) model.errors)
            ]
        ]
    }
```

## Authentication Flow

### Auth module setup

```elm
-- src/Auth.elm
module Auth exposing (User, onPageLoad)

import Auth.Action
import Route exposing (Route)
import Route.Path
import Shared

type alias User =
    { token : String
    , id : String
    , name : String
    }

onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.user of
        Just user ->
            Auth.Action.loadPageWithUser user

        Nothing ->
            Auth.Action.pushRoute
                { path = Route.Path.SignIn
                , query =
                    Dict.fromList
                        [ ( "from", route.url.path ) ]
                , hash = Nothing
                }
```

### Sign-in page sending shared message

```elm
-- In the sign-in page update:
ApiResponded (Ok { token, user }) ->
    ( model
    , Effect.batch
        [ Shared.Msg.SignIn { token = token, name = user.name }
            |> Effect.sendSharedMsg
        , Effect.pushRoute
            { path = Route.Path.Home_
            , query = Dict.empty
            , hash = Nothing
            }
        ]
    )
```

### Shared state handling sign-in

```elm
-- src/Shared.elm
update : Route () -> Msg -> Model -> ( Model, Effect msg )
update route msg model =
    case msg of
        Shared.Msg.SignIn { token, name } ->
            ( { model | user = Just { token = token, name = name } }
            , Effect.none
            )

        Shared.Msg.SignOut ->
            ( { model | user = Nothing }
            , Effect.pushRoute
                { path = Route.Path.SignIn
                , query = Dict.empty
                , hash = Nothing
                }
            )
```

## JavaScript Interop (Ports)

### Flags - pass data from JS to Elm on startup

```js
// src/interop.js
export const flags = () => {
    return {
        user: JSON.parse(window.localStorage.getItem("user") || "null"),
        apiUrl: import.meta.env.VITE_API_URL || ""
    }
}
```

### Ports - send data between Elm and JS at runtime

```elm
-- In src/Effect.elm (must be port module)
port module Effect exposing (..)

port sendToLocalStorage : { key : String, value : Json.Encode.Value } -> Cmd msg
port receiveFromLocalStorage : (Json.Decode.Value -> msg) -> Sub msg
```

```js
// src/interop.js
export const onReady = ({ app }) => {
    if (app.ports?.sendToLocalStorage) {
        app.ports.sendToLocalStorage.subscribe(({ key, value }) => {
            window.localStorage.setItem(key, JSON.stringify(value))
        })
    }
}
```

## Component Patterns

### 1. Simple view function (stateless, generic msg)

```elm
module Components.Badge exposing (view)

view : { label : String } -> Html msg
view props =
    Html.span
        [ Html.Attributes.class "badge" ]
        [ Html.text props.label ]
```

### 2. Settings/builder pattern (configurable, no state)

```elm
module Components.Button exposing
    ( Button, new, view
    , withStyleDanger, withDisabled
    )

type Button msg
    = Settings
        { label : String
        , onClick : msg
        , style : Style
        , disabled : Bool
        }

type Style = Default | Danger

new : { label : String, onClick : msg } -> Button msg
new props =
    Settings
        { label = props.label
        , onClick = props.onClick
        , style = Default
        , disabled = False
        }

withStyleDanger : Button msg -> Button msg
withStyleDanger (Settings s) =
    Settings { s | style = Danger }

withDisabled : Bool -> Button msg -> Button msg
withDisabled d (Settings s) =
    Settings { s | disabled = d }

view : Button msg -> Html msg
view (Settings s) =
    Html.button
        [ Html.Events.onClick s.onClick
        , Html.Attributes.disabled s.disabled
        , Html.Attributes.class
            (case s.style of
                Default -> "btn"
                Danger -> "btn btn-danger"
            )
        ]
        [ Html.text s.label ]
```

### 3. Stateful component (has own Model/Msg/update)

```elm
module Components.Dropdown exposing
    ( Dropdown, new
    , Model, init, Msg, update
    , view
    )

type alias Model =
    { isOpen : Bool
    , selected : Maybe String
    }

init : Model
init =
    { isOpen = False, selected = Nothing }

type Msg
    = Toggled
    | Selected String

type Dropdown msg
    = Settings
        { options : List String
        , toMsg : Msg -> msg
        , onSelect : String -> msg
        }

-- Parent page wires toMsg and onSelect to integrate
```

## Subscriptions

```elm
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\w h -> WindowResized w h)
        , if model.dropdownOpen then
            Browser.Events.onClick (Decode.succeed ClickedOutside)
          else
            Sub.none
        ]
```
