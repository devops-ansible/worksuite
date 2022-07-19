#!/usr/bin/env bash

set -e

rm -rf           "${WORKINGDIR}"
mkdir -p "${WD}"
ln -s    "${WD}" "${WORKINGDIR}"

if [ "$CRON" = true ] ; then
    export START_CRON=1
fi

# ensure / create additional users from JSON
usernames=$( echo "${USER_DEFINITION:-{\}}" | jq -r 'keys[]' )

# SSH Authorized File Location
rx='^AuthorizedKeysFile'
authorizedKeysLocation="$( cat /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* 2>/dev/null | grep "${rx}" | sed "s/${rx}\s*//g" | cut -d" " -f1 )"

set +e

for u in $( echo "${usernames}" ); do

    # below, we'll use `getent` worked with `cut`
    # (source DB: /etc/passwd)
    #
    # -f1 username
    # -f2 'x' - historical password, non-relevant
    # -f3 UID
    # -f4 GID
    # -f5 description
    # -f6 home directory
    # -f7 starting shell

    # get user definition from JSON variable;
    # convert keys of user definition dictionary to lower case,
    # so the below handling can be as easy as possible.
    userinfo=$( echo "${USER_DEFINITION:-{\}}" | jq --arg user "${u}" '.[$user] | walk( if type == "object" then with_entries( .key |= ascii_downcase ) else . end )' )

    if id "${u}" &>/dev/null; then
        echo -e "\033[0;30;42m User \"${u}\" already exists. \033[0m"

        # home directory
        jKey="home"
        if [ $( echo "${userinfo}" | jq --arg key "${jKey}" 'has($key)' ) = "true" ]; then
            cVal="$( getent passwd "${u}" | cut -d: -f6 )"
            nVal="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
            if [ "${cVal}" != "${newHome}" ]; then
                echo -e "\033[0;30;42m Adjusting home directory of user \"${u}\" to \"${nVal}\". \033[0m"
                usermod -d "${nVal}" -m "${u}"
            fi
        fi

        # login shell
        jKey="shell"
        if [ $( echo "${userinfo}" | jq --arg key "${jKey}" 'has($key)' ) = "true" ]; then
            cVal="$( getent passwd "${u}" | cut -d: -f7 )"
            nVal="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
            if [ "${cVal}" != "${nVal}" ]; then
                echo -e "\033[0;30;42m Adjusting login shell of user \"${u}\" to \"${nVal}\". \033[0m"
                chsh -s "${nVal}" "${u}"
            fi
        fi
    else

        # retrieve login shell
        jKey="shell"
        newShell="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
        if [ "${newShell}" = "null" ]; then
            newShell="/sbin/nologin"
        fi

        # retrieve user home directory
        jKey="home"
        newHome="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
        if [ "${newHome}" != "null" ]; then
            echo -e "\033[0;30;42m Creating user \"${u}\" with login shell \"${newShell}\" and home directory \"${newHome}\". \033[0m"
            useradd -s "${newShell}" -d ${newHome} "${u}"
        else
            echo -e "\033[0;30;42m Creating user \"${u}\" with login shell \"${newShell}\". Home directory will be default. \033[0m"
            useradd -s "${newShell}" "${u}"
        fi
    fi

    # UID
    jKey="uid"
    if [ $( echo "${userinfo}" | jq --arg key "${jKey}" 'has($key)' ) = "true" ]; then
        cVal="$( getent passwd "${u}" | cut -d: -f3 )"
        nVal="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
        if [ "${cval}" != "${nVal}" ]; then
            echo -e "\033[0;30;42m Adjust user UID \"${u}\" to \"${nVal}\". \033[0m"
            usermod -u "${nVal}" "${u}"
        fi
    fi

    # GID
    jKey="gid"
    if [ $( echo "${userinfo}" | jq --arg key "${jKey}" 'has($key)' ) = "true" ]; then
        cVal="$( getent passwd "${u}" | cut -d: -f4 )"
        nVal="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
        if [ "${cval}" != "${nVal}" ]; then
            echo -e "\033[0;30;42m Adjust user GID \"${u}\" to \"${nVal}\". \033[0m"
            usermod -g "${nVal}" "${u}"
        fi
    fi


    # user details not in /etc/passwd

    # password
    jKey="pwd"
    if [ $( echo "${userinfo}" | jq --arg key "${jKey}" 'has($key)' ) = "true" ]; then
        nVal="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
        echo -e "\033[0;30;42m Ensure user password \"${u}\". \033[0m"
        echo "${u}:${nVal}" | chpasswd
    fi

    # primary group
    jKey="group"
    if [ $( echo "${userinfo}" | jq --arg key "${jKey}" 'has($key)' ) = "true" ]; then
        nVal="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
        echo -e "\033[0;30;42m Adjust primary group for user \"${u}\" to \"${nVal}\". \033[0m"
        usermod -g "${nVal}" "${u}"
    fi

    # (multiple) secondary group(s)
    jKey="groups"
    if [ $( echo "${userinfo}" | jq --arg key "${jKey}" 'has($key)' ) = "true" ]; then
        nVal="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
        echo -e "\033[0;30;42m Ensure user \"${u}\" to be member of defined secondary groups. \033[0m"
        usermod -a -G "${nVal}" "${u}"
    fi

    # ensuring SSH keys
    jKey="sshkeys"
    if [ $( echo "${userinfo}" | jq --arg key "${jKey}" 'has($key)' ) = "true" ]; then
        nVal="$( echo "${userinfo}" | jq -r --arg key "${jKey}" '.[$key]' )"
        echo -e "\033[0;30;42m Ensure authorized keys for user \"${u}\". \033[0m"
        curHome="$( getent passwd "${u}" | cut -d: -f6 )"
        userAuthKeyFilename="$( echo "${authorizedKeysLocation}" | sed "s/%u/${u}/g" )"
        if [ "${userAuthKeyFilename}" = "" ]; then
            userAuthKeyFilename=".ssh/authorized_keys"
        fi
        subPathLoc="$( dirname "${userAuthKeyFilename}" )"
        userAuthKeyFileLoc="$( mkdir -p "${curHome}"; cd "${curHome}"; chown -R "${u}" ./; mkdir -p "${subPathLoc}"; cd "${subPathLoc}"; chown -R "${u}" ./; pwd )/$( basename "${userAuthKeyFilename}" )"
        printf "${nVal}" > "${userAuthKeyFileLoc}"
    fi

done
