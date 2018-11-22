#!/usr/bin/env sh
set -e
set -u
set -x

# Creating a MONGODUMP snapshot to disk
mkdir -p /backup
DATE=`date +%Y-%m-%d`
mongodump --uri=${MONGO_URI} --gzip --archive=/backup/mongodump-${ENV}-${DATE}.tar.gz 
ls -lh /backup

# Uploading snapshot to S3
aws s3 sync /backup/ s3://${AWS_S3_BUCKET_NAME}/${AWS_S3_BUCKET_PREFIX}

# Notification to slack
if [ -z ${SLACK_NOTIFICATION_URL+x} ]; then 
    echo "SLACK_NOTIFICATION_URL is unset, this won't affect the backup but you won't get notified if something went wrong"; 
else 
    curl -X POST --data-urlencode "payload={\"username\": \"MONGODUMP Backup Script\", \"text\": \"Backup of MONGO:${ENV} ran without issues.\n $(ls -lh /backup) \", \"icon_emoji\": \":floppy_disk:\"}" ${SLACK_NOTIFICATION_URL}
fi
