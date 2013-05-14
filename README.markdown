# muttqt #

`muttqt` is a command line program to facilitate querying various email address
storage solutions from mutt.

## Overview ##

`muttqt` is designed to be called by the [mutt][] [query_command][qc] to provide
a single entry for multiple email address storage locations.  

`muttqt` currently interfaces with mutt aliases files, a database of email
addresses that you have sent emails to, as well as functionality to communicate
with other external tools, such as:

- [contacts][] - a small tool that talks to the Mac OS X Address Book
- [goobook][] - a Python program that accesses your Google contacts
- [mu][] - mu's cfind command, part of the maildir indexing toolkit

`muttqt` requires `python` and `sqlite3`.  It has been tested with `python` 2.7,
but should work with earlier versions.

## Advantages over lbdb ##

- Actively supported.
- Easy to extend.  As long as the external tools provide their output in the
  proper format, no code changes to `muttqt` need to be made.
- Stores email addresses you have sent messages to in either aSqlite3 database
  or a flat text file (lbdb-compatible).
- UTF-8 support.  

## Installing ##

It can be installed by running

```sh
make
make install
```

If you would like to install it in a location other than */usr/local*, use the
prefix setting when running `make install` like so:

```sh
make prefix=/path/to/install install
```

You can also install via [homebrew][] on OS X.  The formula is not yet in the [homebrew][] main repository, so it can be installed from my github page:

```sh
brew install https://raw.github.com/tgray/homebrew-tgbrew/master/muttqt.rb
```

On OS X, you will probably also want to install the `contacts` program.  It can
be installed easily by using [homebrew][]:

```sh
brew install https://raw.github.com/tgray/homebrew-tgbrew/master/contacts2.rb
```

## Configuring ##

muttqt's configuration and data files are stored in the `~/.muttqt` directory.
The configuration is called `muttqt.conf`.  To generate a default configuration
file, run `muttqt --write-config`.  An annotated version of this conf file can be found in *scripts/mutt.conf* in the source release or in */usr/local/share/muttqt/muttqt.conf* when installed.

muttqt is set up to utilise an Sqlite3 database for its sent email address
storage.  This can be changed to a flat text file that is lbdb compatible by
changing the 'format' parameter in the 'sent' section to 'text'.

The Sqlite3 back end is recommended over the flat text file one.  As of now, duplicates are not scrubbed from the file when using the 'text' back end.

### Helpers ###

To add data sources, add an entry to the 'helpers' item in the 'global' section.  The default entry is:

```ini
helpers = mutt_alias, sent
```

The order of the entries determines the output ordering.

### External helpers ###

Even though the default configuration file is not set up to query the following tools, it has sections for [contacts][] (osx_abook), [goobook][], and [mu][].  To use any of these external helpers, assuming they have been installed, add the appropriate one to the 'helpers' line.

The section name in the conf for an external helper program is arbitrary and can be set to whatever you want.  However, it must be the same as what is entered in the 'helpers' line.

The settings available for an external helper program are:

* *cmd*:
  The CLI command that is used to run a search.  The query argument is
  appended to the end of this.

* *text*:
  The text used in the search results in the third field.  If this is
  left blank, the helper name is used.

* *cols*:
  The columns of the helper tool's output to use.  Defaults to the
  first two.  The content of this output should be the email address followed by
  the name of the contact.

* *ignore_first*:
  Ignore the first line of output.  Defaults to *false*.

## Example Usage ##

This returns all matches for *somename* from all of your configured data sources:

```sh
muttqt -q somename
```

The following usage will store any email address in the To, CC, or BCC headers
and store them in the sent address data file.

```sh
cat email.txt | muttqt -f
```

To automate this harvesting of emails, see the section "Setting up sent email
integration".

## Setting up mutt ##

### Querying ###

To configure mutt to use muttqt, set the following in your muttrc file:

```sh
set query_command="/usr/local/bin/muttqt -q '%s'"
```

### Setting up sent email integration ###

The `muttqt -f` command provides a method of searching the To, CC, or BCC
headers of input data.  An easy way to automate address capture is to set the
mutt [sendmail][] command to a wrapper script.  Either use the `tee` command to
split the input message to both muttqt and your sendmail program, or copy the
input mail to a temporary file.  Here is a short example of the tee method:

```bash
#!/bin/bash
tee >(muttqt -f) | sendmail $*
```

Here is an example of the temp file method, useful if you want to do other things
with your email message before sending:

```sh
#!/bin/sh -
muttqt='/usr/local/bin/muttqt -f'

sendmailbin='sendmail'

# save msg in file to re-use it for multiple tests
t=`mktemp -t mutt.XXXXXX` || exit 2
cat > $t

# q all messages first
cat $t | ($muttqt)
cat $t | ${sendmailbin}
rm -f $t
```

The above script works on OS X.  One might need to change the `mktemp` command
to work on other OSes.  These scripts can be found in the *scripts* directory of
the source distribution, or in the */usr/local/share/muttqt* directory.

## Other commands ##

### Importing your lbdb sent addresses ###

Run the following (pointing the command at the appropriate file):

```sh
muttqt -i ~/.lbdb/m_inmail.list
```

### Exporting the sent SQL database ###

Running the following will produce an `lbdb` compatible file:  

```sh
muttqt -d output.txt
```

This file can be edited and reimported to `muttqt` in the same manner as an
`lbdb` sent address file.

### Editing and pruning the databse ###

Running `muttqt --print-sent` will display every address in the sent mail
database, prefixed by the SQL row id.  If you would like to remove a specific
set of addresses, run `muttqt --remove-sent row_id`, where *row_id* are the row
ids of the addresses you would like to remove, separated by commas.

If you would like to remove all addresses last used before a certain date, run:

```sh
muttqt --date-prune date
```

where *date* is in a YYYY-MM-DD format.

## Motivation ##

I've used [lbdb][] for years, but began to have problems compiling the Mac OS X
Address Book tool since [lbdb][] is basically abandoned.  I went so far as to
actually pick it up, hack on it a bit, and put [my version][tglbdb] on github.
This is the version that can be found on the [homebrew][] packaging system for
Mac OS X.

So, I decided I could probably write a stripped down, easy-to-maintain version
in Python.  All I needed to do was write a small Objective C tool to interface
with the Mac OS X Address Book ([done][contacts]) and then hack a bit at the
Python code.


[mutt]: http://www.mutt.org
[qc]: http://dev.mutt.org/doc/manual.html#query
[lbdb]: http://www.spinnaker.de/lbdb/
[tglbdb]: https://github.com/tgray/lbdb
[homebrew]: https://github.com/mxcl/homebrew
[contacts]: https://github.com/tgray/contacts
[goobook]: https://pypi.python.org/pypi/goobook/
[mu]: http://www.djcbsoftware.nl/code/mu/
[sendmail]: http://www.mutt.org/doc/devel/manual.html#sendmail

## Developer Info ##

muttqt is written by [Tim Gray][tggit].  It's obviously inspired by [lbdb][].

The muttqt homepage can be located on github at <http://tgray.github.io/muttqt/>.

[tggit]: https://github.com/tgray

## License ##

`muttqt` is released under an Apache License 2.0.  Please see the
`LICENSE.markdown` file included with the distribution.
