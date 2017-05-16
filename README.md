# UPSOURCE

**upsource** updates the local file system from remote sources. It is
designed as a lightweight provisioning system.

upsource is controlled by **sourcetab**s, which are text files composed of lines
 of the following form:

  *sourcetype* *mountpoint* *source* [VAR=VAL]*

where *mountpoint* is a path in the local file system, *source* is a
remote source, and *sourcetype* determines how to fetch or update from
*source*, which is written or updated into *mountpoint*.  Some example
sourcetypes are *git*, *svn*, or *s3*.


The rest of the sourcetab line consists of environment variable
bindings which are passed to the update method. Some environment
variables have standard interpretations used by update handlers:

* **OWNER** specifies the owner of the tree beneath *mountpoint*;
* **GROUP** specifies the group of the tree beneath *mountpoint*;
* **FILEMODE** specifies the file mode (an argument to **chmod**) of the
tree beneath *mountpoint*;
* **SSH_USER** specifies the username for SSH connections used by handlers;
* **SSH_KEY** specifies the identity key for SSH connections used by handlers;
* **ENVSOURCE** specifies a file to be read into the handler

The command **upsource** with an argument processes either the argument
(if it's a file) or the *name*.srctab files within it (if it's a directory.

When **upsource** is called without any argments, it processes the
default sourcetabs of the form *sourcetype*.sourcetab in
/etc/upsource.d/. (This file location may vary).

Sourcetab handlers are defined in the directory
/usr/lib/upsource/handlers/*sourcetype*.upsource; they are normally
shell scripts and adding a new sourcetype is as simple as adding a new
(executable) file of this form.
