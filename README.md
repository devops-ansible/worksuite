# Worksuite Container with some Tools and SSH

OpenLDAP Server based on devopsansiblede/baseimage:latest. Supports data loading via volume mount as well as SSL based LDAP (ldaps).

## ENV Variables

| env                   | default               | change recommended | description |
| --------------------- | --------------------- |:------------------:| ----------- |
| `ROOT_PASSWORD`       | `ChangeMeByEnv`       | yes                | Password for root User |
| `UBUNTU_PASSWORD`     | `ChangeMeByEnv`       | yes                | Password for ubuntu User |

## Usage

### Container Parameters

Start a new openldap server instance, import config & data.ldif's from another instance and persist the state in _data_
```sh
docker run -d -p 22:229 --name worksuite devopsansiblede/worksuite:latest
```

### Volumes


### Useful File Locations

