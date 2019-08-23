#!/bin/bash

RECORDINGS_DIR=$1

# upload to dropbox
/usr/bin/jitsi_uploader.sh $RECORDINGS_DIR >> {{ .Env.JIBRI_LOGS_DIR }}/upload.log

exit 0
