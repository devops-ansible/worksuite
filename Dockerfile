FROM       devopsansiblede/baseimage

MAINTAINER Felix Kazuya <me@felixkazuya.de>

# Umgebungsvariablen
ENV USER_DEFINITION "{}"
ENV CRON            "false"
ENV WD              "/home/ubuntu"
# DO NOT CHANGE WORKINGDIR!
ENV WORKINGDIR      "/workingdir"
# deprecated
ENV ROOT_PASSWORD   "ChangeMeByEnv"
ENV UBUNTU_PASSWORD "ChangeMeByEnv"

# Portfreigaben
EXPOSE 22

# Dateien reinkopieren
COPY files/ /install/

# organise file permissions and run installer
RUN chmod a+x /install/install.sh && \
    /install/install.sh && \
    rm -rf /install

USER    "root"
WORKDIR "${WORKINGDIR}"

# Startbefehl
# Combining ENTRYPOINT and CMD allows you to specify the default executable for your image while also providing default arguments to that executable which may be overridden by the user.
# When both an ENTRYPOINT and CMD are specified, the CMD string(s) will be appended to the ENTRYPOINT in order to generate the container's command string. Remember that the CMD value can be easily overridden by supplying one or more arguments to `docker run` after the name of the image.
# Entrypoint explizit override needed
# Entrypoint needs new value for each argument ["/bin/ping","-c","4"]
# CMD Overwrite by arguments after run (same as Entrypoint ["localhost"])

ENTRYPOINT [ "entrypoint" ]
CMD [ "/usr/sbin/sshd", "-D" ]
