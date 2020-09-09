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

* **Elixir:** The [Elixir](https://elixir-lang.org/) language makes it easy to build and maintain large concurrent systems.
* **Developer-friendly:** Developer joy is just as important as user joy.

## Status

Already in use in production, for sites that don't need these features yet to be ported over from Imagine 5:

* Photo galleries
* Scheduling/expiration of posts
* Page list calendar view
* Page list RSS feed
* User permissions and draft approval system
* Search function

## Installation

See [INSTALL.md](https://github.com/ImagineCMS/imagine_cms/blob/main/INSTALL.md).

## Deployment

See [DEPLOY.md](https://github.com/ImagineCMS/imagine_cms/blob/main/DEPLOY.md).

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
