---
name: Elm Land Development
description: This skill should be used when the user asks to "create an Elm Land app", "add a page", "add a layout", "set up authentication", "make an API call in Elm Land", "review Elm Land code", "fix Elm Land routing", "add shared state", "use effects", "configure elm-land.json", or is developing, reviewing, or debugging an Elm Land web application.
version: 0.1.0
---

# Elm Land Development

Elm Land is a production-ready framework for building reliable web applications in Elm. It provides file-based routing, built-in dev server, and conventions for structuring Elm applications with zero runtime exceptions.

## Core Concepts

### The Elm Architecture

Every page follows three core pieces:

- **Model** - Application state/data
- **Update** - How the model changes based on messages (`Msg`)
- **View** - How to display the model as HTML

### Project Structure

```
project/
├── elm.json              # Elm package dependencies
├── elm-land.json         # Framework configuration
├── src/
│   ├── Pages/            # File-based routing (URL = filename)
│   ├── Layouts/          # Reusable page wrappers
│   ├── Components/       # Shared UI components
│   ├── Shared.elm        # Shared state logic
│   ├── Shared/Model.elm  # Shared data definition
│   ├── Shared/Msg.elm    # Shared messages
│   ├── Effect.elm        # Custom side-effects
│   ├── Auth.elm          # Authentication logic
│   └── interop.js        # JavaScript interop (ports)
└── static/               # Static assets (CSS, images)
```

### File-Based Routing

| Page File | URL | Type |
|-----------|-----|------|
| `Home_.elm` | `/` | Homepage |
| `SignIn.elm` | `/sign-in` | Static route |
| `Settings/Account.elm` | `/settings/account` | Nested static |
| `User_.elm` | `/:user` | Dynamic route |
| `Users/Id_.elm` | `/users/:id` | Dynamic parameter |
| `Blog/ALL_.elm` | `/blog/*` | Catch-all |
| `NotFound_.elm` | `/*` | 404 page |

Trailing underscore (`_`) marks dynamic segments. `ALL_` is the catch-all pattern.

### Page Types

Pages range from simple to full-featured:

- **`page:view`** - Static view, no state (`View msg`)
- **`page:sandbox`** - Has `Model`/`Msg`/`update`, no side-effects
- **`page:element`** - Has `Cmd`/`Sub` for HTTP, subscriptions
- **`page` (default)** - Full access: `Effect`, `Shared.Model`, `Route`, auth

### Effects

Effects are Elm Land's abstraction over `Cmd` for side-effects:

```elm
Effect.none                         -- No side-effect
Effect.batch [ e1, e2 ]            -- Multiple effects
Effect.sendCmd cmd                  -- Wrap a standard Cmd
Effect.pushRoute { path, query, hash }  -- Navigate
Effect.replaceRoute { ... }         -- Replace URL (no history entry)
Effect.loadExternalUrl "..."        -- External navigation
Effect.back                         -- Browser back
Effect.sendMsg msg                  -- Send message to self
```

Custom effects are defined in `src/Effect.elm` and can send shared messages:

```elm
Effect.sendSharedMsg (Shared.Msg.SignIn { token = "..." })
```

### Shared State

Shared state persists across page navigation. Customize with `elm-land customize shared`:

- `Shared/Model.elm` - Define shared data (user session, theme, window size)
- `Shared/Msg.elm` - Define shared messages (SignIn, SignOut)
- `Shared.elm` - Handle shared init/update logic

Pages access shared state via `Shared.Model` parameter.

### Authentication

Customize with `elm-land customize auth`. Define `Auth.User` type and `onPageLoad`:

```elm
onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.user of
        Just user -> Auth.Action.loadPageWithUser user
        Nothing -> Auth.Action.pushRoute { path = Route.Path.SignIn, ... }
```

Protect pages by adding `Auth.User` as the first parameter to `page`.

### Layouts

Layouts wrap pages with reusable UI. Define `Props` to configure per-page. Attach to pages via `Page.withLayout`.

### JavaScript Interop

Use `src/interop.js` for:
- **`flags()`** - Pass initial data to Elm (localStorage, env vars)
- **`onReady({ app })`** - Subscribe to ports after Elm initializes

## CLI Quick Reference

```sh
elm-land init <folder>           # New project
elm-land server                  # Dev server (port 1234)
elm-land build                   # Production build
elm-land add page <url>          # Add full page
elm-land add page:view <url>     # View-only page
elm-land add page:sandbox <url>  # Page with Model/Msg
elm-land add page:element <url>  # Page with Cmd/Sub
elm-land add layout <name>       # Add layout
elm-land customize <module>      # Customize shared|auth|effect|view|not-found
elm-land routes                  # List all routes
```

## Code Review Checklist

When reviewing Elm Land code, verify:

1. **Routing** - Page filenames match intended URLs; dynamic segments use trailing `_`
2. **Page type** - Simplest page type used (don't use `page:element` if `page:view` suffices)
3. **Effects** - Use `Effect` module, not raw `Cmd` in full pages
4. **Shared state** - Only truly shared data lives in `Shared.Model`
5. **Auth** - Protected pages accept `Auth.User` as first `page` parameter
6. **Layouts** - Reusable chrome extracted to layouts, not duplicated across pages
7. **Components** - Follow appropriate pattern (view function, settings pattern, or stateful)
8. **JSON decoders** - Properly handle all API response shapes
9. **Error states** - HTTP results handled for both `Ok` and `Err` cases
10. **No runtime exceptions** - No `Debug.todo`, no partial pattern matches in production
11. **Styling** - Use Tailwind CSS for styling, never `elm-ui`. Elm Land projects use Tailwind via `Html.Attributes.class`

## Additional Resources

### Reference Files

- **`references/common-operations.md`** - Detailed code examples for navigation, API calls, forms, auth, ports, and components
- **`references/configuration.md`** - Full `elm-land.json` configuration reference and environment variables

### Examples

- **`examples/page-with-api.elm`** - Page that fetches and displays API data
- **`examples/auth-protected-page.elm`** - Auth-protected page with layout
