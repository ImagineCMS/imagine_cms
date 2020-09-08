# Imagine 6 - Elixir Phoenix-powered CMS

[![Hex Version](https://img.shields.io/hexpm/v/imagine_cms.svg)](https://hex.pm/packages/imagine_cms)
[![Docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/imagine_cms)
[![License](https://img.shields.io/github/license/ImagineCMS/imagine_cms.svg)](https://github.com/ImagineCMS/imagine_cms/blob/main/LICENSE)

A ground-up Elixir rewrite of [Imagine 5](https://github.com/anamba/imagine_cms) (Rails), maintaining database compatibility as much as possible, to the point that both 5 and 6 can be run side-by-side, on the same database, to make the transition as smooth as possible.

## Imagine CMS - A CMS that makes designers, developers and content editors happy

Imagine CMS is a web content management system first developed by Bigger Bird Creative, Inc. in 2006 for its clients.

Most CMSes come with a learning curve: not a big deal for daily users, but clients who only make changes once a month or so tend to forget everything by the next time they log in. Yet simpler systems don't offer enough flexibility to allow us to do what we want to do as designers and developers.

So we created a new kind of CMS, one that is easy for clients to use, stays out of our way, and provides a basic level of automation.

## Philosophy

* Security
* Convenience
* Ease of Use
* Efficiency
* Flexibility

Pick any 5. 😀

## Key Features for Content Editors

* **Built to scale:** Designed to operate sites with thousands of pages each, with the potential to scale further. This is a CMS you won't outgrow.
* **Drafts (version control):** Pages and templates are versioned. You can undo nearly anything. Don't be afraid to experiment!
* **Edit your way:** Switch between WYSIWYG and straight HTML at any time. (NOTE: Requires [Redactor](https://imperavi.com/redactor) editor.)
* **Redirects:** You can create redirects by yourself, within the CMS.

## Key Features for Managers

* **Draft approval system:** Restrict users from publishing drafts in certain areas, requiring an approval step, grant them full access in other areas. You're in control.

## Key Features for Developers

* **Elixir:** [Elixir](https://elixir-lang.org/) makes it easy to build and maintain large systems.
* **Developer-friendly:** Developer joy is just as important as user joy.

## Status

Already in use in production, for sites that don't need these features yet to be ported over from Imagine 5:

* Photo galleries
* Scheduling/expiration of posts
* Page list calendar view
* Page list RSS feed
* User permissions and draft approval system

## Installation

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

<!-- Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/imagine_cms](https://hexdocs.pm/imagine_cms). -->

## Getting Help

You can get paid support and hosting for Imagine CMS straight its creators: [Bigger Bird Creative, Inc.](https://biggerbird.com)

## Contributing

Issues and pull requests welcome, especially related to code cleanup, testing, and documentation.

## Imagine 5 -> 6 Migration Notes

Migrations from 5 to 6 are possible with a little bit of elbow grease.

Template syntax is close, but not identical. To allow Imagine 5 and 6 to run together without conflicts, the Imagine 6 migration process creates a separate `content_eex` field on each template, leaving the original `content` field untouched.

* The deprecated `insert_object` style calls have been removed.
* Naturally, any Ruby/Rails/ERB stuff must be removed or rewritten.
* No "dynamic" page list configuration is possible from within a page. All configuration must be done at the template level. This may change in the near future.

## Note re: associations

Foreign keys are intentionally not created, to allow restoration of CMS objects found to be deleted by accident (using version entries). A cleanup process (not yet created) will delete old orphaned objects at a later time, after a certain amount of time has passed.