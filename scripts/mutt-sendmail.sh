#!/bin/sh -
# 
# This script is used in place of the system's sendmail command in the muttrc.
# Unlike the other script, mutt-sendmail.bash, this script does not rely on
# bash or tee.  Instead it copies the outgoing message to a temp file before
# sending it to the SMTP program and to muttqt for email harvesting.  This
# arrangement allows you to run other tests on the message body (checking for
# attachments, etc.) or allows you to check for a network connection before
# attempting to deliver the message.
# 
# It has only been tested on Mac OS X.  I would assume the `mktemp` command is
# different on other operating systems.
#
# To use it, set the following in your muttrc:
#   set sendmail="/path/to/mutt-sendmail.sh"

# change this to the path of muttqt
muttqt='/usr/local/bin/muttqt -f'

# Change this to the path of your SMTP program
sendmailbin='sendmail'

# save msg in file to re-use it for multiple tests
t=`mktemp -t mutt.XXXXXX` || exit 2
cat > $t

# q all messages first
cat $t | ($muttqt)
cat $t | ${sendmailbin}
rm -f $t
