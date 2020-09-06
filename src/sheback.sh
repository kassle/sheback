#! /usr/bin/env bash

function usage() {
    echo "ERR: ${1}"
    echo
    echo "usage: "
    echo "  Backup:"
    echo "    $0 [my.profile]"
    echo ""
    echo "  Restore:"
    echo "    $0 [my.profile] [backup.name]"
    exit 1
}

function verifyProfile() {
    . ${1}
    retval=0

    if [ -z ${NAME} ]; then
        retval=1
    elif [ -z ${DESTDIR} ]; then
        retval=2
    elif [ ! -d ${DESTDIR} ]; then
        retval=3
    elif [ -z "${FILES}" ]; then
        retval=4
    fi

    unset NAME DESTDIR FILES
    return ${retval}
}

function processBackup() {
    . ${1}

    echo "Process profile: ${NAME}"
    echo -n "    - prepare backup: "
    TIMESTAMP=`date +%Y%m%d%H%M`
    BACKUPNAME="${NAME}_${TIMESTAMP}"
    BACKUPDIR="${DESTDIR}/${BACKUPNAME}"
    echo ${BACKUPNAME}
    if [ -d ${BACKUPDIR} ]; then
        echo "    - backup already exist"
        exit 1
    else
        mkdir -p ${BACKUPDIR}
    fi

    echo "    - packing files"
    BACKUPFILE="${BACKUPDIR}/files.tar.gz"
    tar zcfU ${BACKUPFILE} --directory=/ ${FILES[*]} > /dev/null 2>&1

    echo "    - clean up"
    unset NAME DESTDIR FILES TIMESTAMP BACKUPNAME BACKUPDIR BACKUPFILE

    echo "    - done"
    exit 0
}

function processRestore() {
    . ${1}

    echo "Process profile: ${NAME}"
    BACKUPNAME=${2}
    echo "    - restore backup: ${BACKUPNAME}"
    BACKUPDIR="${DESTDIR}/${BACKUPNAME}"
    if [ ! -d ${BACKUPDIR} ]; then
        echo "    - not exist"
        exit 1
    fi

    BACKUPPROFILE="${BACKUPDIR}/profile"
    if [ ! -f ${BACKUPPROFILE} ]; then
        echo "    - corrupted backup"
        exit 1
    fi

    unset NAME DESTDIR FILES
    . ${BACKUPPROFILE}

    echo "    - remove current files"
    for ITEM in "${FILES[@]}"; do
        if [ "/" == ${ITEM} ]; then
            echo "        - skip remove ${ITEM}"
        elif [ "/usr" == ${ITEM} ]; then
            echo "        - skip remove ${ITEM}"
        elif [ -f ${ITEM} ]; then
            echo "        - remove file ${ITEM}"
            rm -f ${ITEM}
        elif [ -d ${ITEM} ]; then
            echo "        - remove dir ${ITEM}"
            rm -rf ${ITEM}
        fi
    done

    BACKUPFILE="${BACKUPDIR}/files.tar.gz"
    if [ -f ${BACKUPFILE} ]; then
        echo " "
        echo "    - restore files"
        tar xf ${BACKUPFILE} --directory=/
    fi

    echo "    - clean up"
    unset NAME DESTDIR FILES TIMESTAMP BACKUPNAME BACKUPDIR BACKUPFILE

    echo "    - done"
    exit 0
}

function main() {
    if [ -z ${1} ]; then
        usage "No profile specified"
    elif [ ! -f ${1} ]; then
        usage "Can't locate profile: ${1}"
    elif [ -z ${2} ]; then
        verifyProfile ${1}
        retval=$?
        if [[ $retval > 0 ]]; then
            usage "Invalid profile format: $retval"
        else
            processBackup ${1}
        fi
    else
        verifyProfile ${1}
        retval=$?
        if [[ $retval > 0 ]]; then
            usage "Invalid profile format: $retval"
        else
            processRestore ${1} ${2}
        fi
    fi
}

main $@