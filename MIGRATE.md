## Imagine 5 -> 6 Migration Notes

NOTE: This document is a work in progress.

Migrations from 5 to 6 are possible with a little bit of elbow grease.

Template syntax is close, but not identical. To allow Imagine 5 and 6 to run together without conflicts, the Imagine 6 migration process creates a separate `content_eex` field on each template, leaving the original `content` field untouched.

* The deprecated `insert_object` style calls have been removed.
* Naturally, any Ruby/Rails/ERB stuff must be removed or rewritten.
* No "dynamic" page list configuration is possible from within a page. All configuration must be done at the template level. This may change in the near future.
