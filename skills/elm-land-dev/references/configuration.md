# Elm Land Configuration Reference

## elm-land.json

Full configuration file structure:

```json
{
  "app": {
    "elm": {
      "development": { "debugger": true },
      "production": { "debugger": false }
    },
    "env": ["API_URL", "NODE_ENV"],
    "html": {
      "attributes": {
        "html": { "lang": "en" },
        "head": {}
      },
      "title": "My App",
      "meta": [
        { "charset": "UTF-8" },
        { "name": "viewport", "content": "width=device-width, initial-scale=1.0" },
        { "name": "description", "content": "My Elm Land app" }
      ],
      "link": [
        { "rel": "stylesheet", "href": "/main.css" },
        { "rel": "icon", "href": "/favicon.ico" }
      ],
      "script": [
        { "src": "/analytics.js", "type": "module" }
      ]
    },
    "router": {
      "useHashRouting": false
    },
    "proxy": {
      "/api": "http://localhost:5000",
      "/auth": "http://localhost:5001"
    }
  }
}
```

### Configuration Sections

#### `elm` - Elm compiler settings

- `development.debugger` - Enable Elm time-travel debugger in dev mode (default: `true`)
- `production.debugger` - Enable debugger in production builds (default: `false`)

#### `env` - Environment variables

Whitelist environment variables accessible in Elm via flags. Only listed variables are exposed. Access in `interop.js`:

```js
export const flags = () => ({
    apiUrl: import.meta.env.ELM_LAND_API_URL
})
```

Environment variables prefixed with `ELM_LAND_` are automatically available.

#### `html` - HTML template

Controls the generated `index.html`:

- `attributes.html` - Attributes on `<html>` tag
- `title` - Default page title (overridden by `View.title`)
- `meta` - `<meta>` tags (SEO, viewport, charset)
- `link` - `<link>` tags (stylesheets, favicon)
- `script` - `<script>` tags (external JS)

#### `router` - Routing configuration

- `useHashRouting` - Use `/#/path` URLs instead of `/path`. Enable for static hosting without server-side routing (GitHub Pages, S3).

#### `proxy` - Dev server proxy

Forward API requests during development. Keys are URL prefixes, values are target servers. Only active during `elm-land server`.

## elm.json

Standard Elm package configuration. Install packages with:

```sh
npx elm install author/package
```

Common packages for Elm Land apps:

| Package | Purpose |
|---------|---------|
| `elm/http` | HTTP requests |
| `elm/json` | JSON encoding/decoding |
| `elm/time` | Time/date operations |
| `elm/url` | URL parsing |
| `elm/browser` | Browser APIs (events, navigation) |
| `elm/regex` | Regular expressions |
| `elm-community/list-extra` | Extended List functions |
| `elm-community/maybe-extra` | Extended Maybe functions |
| `NoRedInk/elm-json-decode-pipeline` | Cleaner JSON decoders |
| `rtfeldman/elm-css` | Type-safe CSS |

## Customizable Modules

Modules customized via `elm-land customize <name>`:

| Module | Command | Purpose |
|--------|---------|---------|
| `Shared` | `elm-land customize shared` | Shared state across pages |
| `Auth` | `elm-land customize auth` | User authentication |
| `Effect` | `elm-land customize effect` | Custom side-effects |
| `View` | `elm-land customize view` | Customize view type |
| `NotFound` | `elm-land customize not-found` | Custom 404 page |

Once customized, the file moves to `src/` and is no longer auto-generated.

## Build Output

`elm-land build` produces optimized output in `dist/`:

```
dist/
├── index.html
├── assets/
│   ├── elm.js        # Compiled + minified Elm
│   └── ...           # Static assets
└── ...               # Files from static/
```

Deploy `dist/` to any static hosting. For SPA routing without hash routing, configure the server to serve `index.html` for all paths.
