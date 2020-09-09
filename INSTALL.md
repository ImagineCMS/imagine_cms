# Installation Process

*This process could definitely be streamlined further. PRs welcome.*

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

Choose and configure your editor (default is [Redactor](https://imperavi.com/redactor), but you must BYOL), then import `imagine_cms`:
```javascript
window.ImagineConfig = {
  // editor: 'article',
  editor: 'redactor',
  redactor: {
    plugins: ['alignment', 'clips', 'properties', 'table', 'video', 'widget'],
    clips: [
      ['Lorem ipsum...', 'Lorem...'],
      ['Red label', '<span class="label-red">Label</span>']
    ],
  }
}

import "imagine_cms";
```

Import the CMS editor styles, either via webpack:
```javascript
import "../../deps/imagine_cms/priv/static/css/imagine_cms.css";
```

Or a CSS tool that supports importing via the package.json "style" attrbute:
```css
@import "imagine_cms"
```

Also make sure to include the js/css for your selected editor in your own webpack bundle. Here is a Redactor example, including the recommended plugins:

```javascript
import "./vendor/redactor/redactor.css";
import "./vendor/redactor/redactor.js";
import "./vendor/redactor/_plugins/alignment/alignment.js";
import "./vendor/redactor/_plugins/clips/clips.css";
import "./vendor/redactor/_plugins/clips/clips.js";
import "./vendor/redactor/_plugins/properties/properties.js";
import "./vendor/redactor/_plugins/table/table.js";
import "./vendor/redactor/_plugins/variable/variable.css";
import "./vendor/redactor/_plugins/variable/variable.js";
import "./vendor/redactor/_plugins/video/video.js";
import "./vendor/redactor/_plugins/widget/widget.js";
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