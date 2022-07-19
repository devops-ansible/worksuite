# Worksuite Container with some Tools and SSH

OpenLDAP Server based on devopsansiblede/baseimage:latest. Supports data loading via volume mount as well as SSL based LDAP (ldaps).

## ENV Variables

| env                   | default               | change recommended | description |
| --------------------- | --------------------- |:------------------:| ----------- |
| `ROOT_PASSWORD`       | `ChangeMeByEnv`       | yes                | Password for root User |
| `UBUNTU_PASSWORD`     | `ChangeMeByEnv`       | yes                | Password for ubuntu User |
| `USER_DEFINITION`     | `{}`                  | yes                | |
| `CRON`                | `false`               | no                 | consider using variables from [Base image](https://g.dev-o.ps/docker-base), in this case `$START_CRON` |
| `WD`                  | `/home/ubuntu`        | yes                | set to the directory, your container should find its home / working directory |
| `WORKINGDIR`          | `/workingdir`         | no                 | Don't touch ... this path has to be equal with build environment of the image so the dynamic workdirectory `$WD` can operate as expected! |

## Usage

### Container Parameters

Start a new openldap server instance, import config & data.ldif's from another instance and persist the state in _data_
```sh
docker run -d -p 229:22 --name worksuite devopsansiblede/worksuite:latest
```

### Volumes


### Useful File Locations

