# Installation Process

Add `imagine_cms` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:imagine_cms, "~> 6.3"}
  ]
end
```

Add `imagine_cms` to your list of dependencies in `package.json`:
```javascript
  "dependencies": {
    "imagine_cms": "file:../deps/imagine_cms",
    // other deps (phoenix, etc.)
  }
```

Import and start `imagine_cms`:

```javascript
import "imagine_cms";

Imagine.start({
  // optional HugeRTE overrides
  hugerte: {}
});
```

Import the CMS editor styles:

```javascript
import "../../deps/imagine_cms/priv/static/css/imagine_cms.css";
```

Or a CSS tool that supports importing via the package.json "style" attrbute:
```css
@import "imagine_cms"
```

Configure the database (`dev.exs` and `prod_secret.exs` in a standard Phoenix app).

Migrations, etc. are simpler if you point it at the same database as your main repo, but you can also use a separate database if needed.

```elixir
config :imagine_cms, Imagine.Repo
  ...
```

Copy in the [migrations](https://github.com/ImagineCMS/imagine_cms/tree/main/priv/repo/migrations) and [seeds](https://github.com/ImagineCMS/imagine_cms/blob/main/priv/repo/seeds.exs) and run them to set up your CMS tables.

Copy in the [routes](https://github.com/ImagineCMS/imagine_cms/blob/main/lib/imagine_web/router.ex), but change the two `LayoutView` module names to the one from your app.

Finally, add a new Plug.Static call to your endpoint, right after the existing one:

```elixir
  plug Plug.Static,
    at: "/",
    from: "./public",
    only: ~w(assets)
```

Also serve HugeRTE's static runtime assets from the dependency:

```elixir
  plug Plug.Static,
    at: "/assets/vendor/hugerte",
    from: {:imagine_cms, "priv/static/vendor/hugerte"},
    gzip: false
```
