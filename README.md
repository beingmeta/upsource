# sourcetab

**Sourcetab** is a utility for automatically updating local files from
  various source repositories. Mappings between local directories and
  external sources are maintained in a configuration file (by default,
  /etc/sourcetab) and are installed or updated as needed.

The sourcetab is a file of lines separated by unindented newlines (so
a line can be continued by just indenting subsequent lines). The
general form of a sourcetab line is:

*sourcetype* *localpath* *remotesource* [environment variables]

A sourcetypes directory contains scripts which are used for each line
with environment variables as set on the sourcetab line.

