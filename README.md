# Worksuite Container with some Tools and SSH

Worksuite image based on devopsansiblede/baseimage:latest. Supports data loading via volume mount. Used to be able to `ssh` into the container and act in it – e.g. in order to allow a dedicated group of persons to access files on a shared docker host via SFTP / SSH when they must not access the whole server contents.

## ENV Variables

| env               | default         | change recommended | description |
| ----------------- | --------------- |:------------------:| ----------- |
| `USER_DEFINITION` | `{}`            | yes                | JSON definition for additional users to be created for SSH Auth. Dictionary with usernames as key, followed by another dictionary – see below. |
| `CRON`            | `false`         | no                 | Consider using variables from [Base image](https://g.dev-o.ps/docker-base), in this case `$START_CRON` |
| `WD`              | `/home/ubuntu`  | yes                | Set to the directory, your container should find its home / working directory |
| `WORKINGDIR`      | `/workingdir`   | no                 | *DON'T TOUCH* ... this path has to be equal with build environment of the image so the dynamic workdirectory `$WD` can operate as expected! |

### The variable `USER_DEFINITION`

JSON definition for additional users to be created for SSH Auth. The environmental variable is a JSON dictionary with usernames as key followed by another JSON dictionary with those keys:

| user definition key | default            | description |
| ------------------- | ------------------ | ----------- |
| `pwd`               | –                  | Password for user |
| `group`             | –                  | Name of effictive, primary login group the user should be assigned to. |
| `shell`             | `/sbin/nologin`    | Login shell for user – by default, the user won't be permitted to login |
| `home`              | `/home/<username>` | User home directory – defaults to Ubuntu default, only to be set if it should be changed. If the user is already existing – e.g. the `www-data` user – the home directory won't be changed if it's not defined. |
| `groups`            | –                  | Comma separated list of non-effective groups the user should be added. *Do not use whitespaces within this groups list!* |
| `sshkeys`           | –                  | `\n` newline separated list of public SSH keys to be added to the user authorized keys for SSH connections. |
| `uid`               | –                  | User ID of user to be created; if not defined, the user will be generated with system default next free uid. |
| `gid`               | –                  | Group ID of user to be created; if not defined, the user will be generated with system default next free gid. |

Since the environmental variable may only contain single line values in almost all deployments, one often needs to simplify the JSON. E.g by using this command and use the result single quoted (be aware of the double escaped newline in JSON as `\\n`!):

```sh
echo '{
   "user1": {
      "pwd":     "$ecre7",
      "shell":   "/bin/bash",
      "home":    "/home/user1",
      "groups":  "sudo,admin",
      "group":   "www-data",
      "sshkeys": "ssh-rsa AAA... contact1\\nssh-rsa AAA... contact2",
      "uid":     "123",
      "gid":     "456"
   },
   "www-data": {
      "shell":   "/bin/zsh",
      "home":    "/var/www",
      "sshkeys": "ssh-rsa AAA... contact2\\nssh-rsa AAA... contact3"
   }
}' | jq -c
```

## Usage

### Container Parameters

Start a new instance of this image:

```sh
docker run -d -p 229:22 --name worksuite devopsansiblede/worksuite:latest
```

## last built

2024-02-04 23:34:03
