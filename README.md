# TinyForge
Copyright (c) 2011 Bart Massey

Welcome to TinyForge!

TinyForge is a couple of tiny shell scripts etc that I use
to maintain my "personal forge",
[BartForge](http://wiki.cs.pdx.edu/bartforge). My personal
forge currently contains links to about 50 small software
projects created over the last 15 years or so.  The world
has moved on: most of these projects have moved to
[Github](http://github.com) or [Gitlab](http://gitlab.com),
leaving only a pointer in my forge.  However, this software
might still be useful in some special situations

## Install and Use

TinyForge is built around [Git](http://git-scm.com),
[ikiwiki](http://ikiwiki.info) and
[SQLite 3](http://www.sqlite.org/), so you'll need these
installed for any hope of success. The forge software
consists of a shell script, `tf-add`, that you run to add
new entries; this script calls another script, `tf-index`,
to make index pages for your forge. (The scripts are written
in Bourne shell with the exception of shell functions, so
they should be pretty portable.) You can also call
`tf-index` manually: for example, if you have made database
changes that need to be reflected in index changes, or if
you have made a change to the index-top.

To start your forge, set up a Git-based ikiwiki site for it,
`git clone` that site to a convenient directory, and `cd`
there.  You will want to make your ikiwiki directory
different from the TinyForge software directory containing
this README, so that they can have separate Git
repositories.

Now run

    sqlite3 forge.db <$TINYFORGEPATH/initdb.sql

where `TINYFORGEPATH` is the path to the TinyForge source
directory, where the `initdb` file lives.  You now have an
empty database. Run

    git add forge.db; git commit

to commit the database.

Next, go back to the TinyForge source directory and copy
`tinyforge.conf` to `/usr/local/etc`. (If you want it
somewhere else, you'll need to edit `tf-add.sh` and
`tf-index.sh`, which is easy.)  In the config file, set the
`FORGENAME` variable to the name of the forge.  You may also
want to set the `FORGEPATH` variable to the absolute path to
the ikiwiki directory.  Copy `index-top.mdwn` into the
ikiwiki directory and edit it to your taste; you'll probably
want to `git commit` it also.  Run `make install` with
appropriate privileges to get `tf-add` and `tf-index`
installed; they install in `/usr/local/bin` by default. (You
may want something different, in which case edit the
`Makefile`.)

You are now ready to create your first TinyForge entry. Pick
a lowercase name with no spaces to act as the "internal
name" for your project. Copy the file `template.mdwn` in the
TinyForge source to *internalname*`.mdwn` in the ikiwiki
directory, and edit it to taste. You may want to copy
`template.mdwn` itself to the ikiwiki directory first, and
customize it for future use.

Finally, run `tf-add` with the appropriate
arguments. `tf-add --help` will give a synopsis.  The
arguments are:

* *intname:* The internal name of the package as described
  above

* *category:* The category name of the package. The list of
  categories can be obtained via `tf-add --help` *category*.

* *visname:* The "visible name" of the package will be used
  in most instances for presentation to the reader.

* *language:* The programming language of the package. The
  list of languages can be obtained via `tf-add --help`
  *language*.

* *langdetail:* An optional descriptive string giving more
  detail about the programming languages used.

* *attrib:* An optional descriptive string giving extra
  authorship information for projects that you did not
  author, or did not solely author, but are nonetheless in
  your forge.

Note that these strings aren't database-sanitized at all, so
characters such as single-quote or double-quote will likely
break things. Don't be too clever, please. Once `tf-add`
succeeds, it will have made a `git` commit. Inspect the commit
as you like, and then `git push`.

Upon visiting your ikiwiki site you should find that you
have a personal forge with a single entry.  Congratulations!

You will likely find that the languages and categories
provided by the initial TinyForge setup are not to your
taste. It is relatively straightforward to tweak `forge.db`
from the `sqlite3` command line to add or delete these. The
main forge information is stored in a table named `master`,
and the languages and categories are in tables named
`languages` and `categories` respectively.  Be careful not
to remove a language or category that is in use. TinyForge
currently doesn't use foreign key constraints, so it won't
protect you from screwing up.  Also, note that the languages
and categories are sorted in their respective index by
category number, not category name. This is considered
minorly a feature, but it's easy to fix in the `tf-index`
script if it's bugging you.

## License

This software is licensed under the "MIT License".  Please
see the file `COPYING` in the source distribution of this
software for license terms.
