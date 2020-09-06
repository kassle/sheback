# sheback

BASH script for backup and restore mechanism

## profile

```
NAME=sample
DESTDIR=/home/kassle/Backup
FILES=(
    'file1'
    'file2'
    'dir1'
    'dir2'
)
MYSQLDBS=(
    'mysql'
    'krybrig'
)
POSTBACKUP_SCRIPT=/usr/libexec/sheback_keeper
POSTRESTORE_SCRIPT=/usr/libexec/sendemail
KEEP_BACKUP_NUM=3
```

Required:

- NAME
- DESTDIR
- FILES

Optional:

- MYSQLDBS
- POSTBACKUP_SCRIPT
- POSTRESTORE_SCRIPT
- KEEP_BACKUP_NUM = used by `sheback_keeper` post-backup script to remove old backup copies

Notes MYSQLDBS:

- will require root or script return error code 5
- assuming access as root user will not require any password

Error Code:

1. Profile name is not set
2. Backup destination dir is not set
3. Backup destination dir is not exist
4. Files is not set (maybe become optional in the next version ?)
5. Mysql database backup is set, but script not executed as root (see Notes about MYSQLDBS)
6. Post backup script is set, but not exist
7. Post restore script is set, but not exist