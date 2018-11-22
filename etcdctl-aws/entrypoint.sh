#!/usr/bin/env sh
set -e
set -u
set -x

# Creating a ETCD snapshot to disk
DATE=`date +%Y-%m-%d`
etcdctl snapshot save /backup/etcd-${DATE}.db 
ls -lh /backup

# Uploading snapshot to S3
aws s3 sync /backup/ s3://${AWS_S3_BUCKET_NAME}/${AWS_S3_BUCKET_PREFIX}

# Notification to slack
if [ -z ${SLACK_NOTIFICATION_URL+x} ]; then 
    echo "SLACK_NOTIFICATION_URL is unset, this won't affect the backup but you won't get notified if something went wrong"; 
else 
    curl -X POST --data-urlencode "payload={\"username\": \"ETCD Backup Script\", \"text\": \"Backup of ETCD ran without issues.\n $(ls -lh /backup) \", \"icon_emoji\": \":floppy_disk:\"}" ${SLACK_NOTIFICATION_URL}
fi
