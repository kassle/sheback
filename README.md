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
```

Notes MYSQLDBS:

- will require root or script return error code 5
- assuming access as root user will not require any password