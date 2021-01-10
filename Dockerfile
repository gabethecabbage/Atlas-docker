FROM ubuntu:18.04


# Var for first config
# Map name
ENV SERVERMAP "Ocean"
# Server password
ENV SERVERPASSWORD ""
# Admin password
ENV ADMINPASSWORD "adminpassword"
# Nb Players
ENV NBPLAYERS 70
# If the server is updating when start with docker start
ENV UPDATEONSTART 1
# if the server is backup when start with docker start
ENV BACKUPONSTART 1
#  Tag on github for atlas server tools
ENV GIT_TAG v1.8.5.5
#ENV GIT_TAG master
# Server PORT (you can't remap with docker, it doesn't work)
ENV SERVERPORT 57550
# Steam port (you can't remap with docker, it doesn't work)
ENV STEAMPORT 5750
# if the server should backup after stopping
ENV BACKUPONSTOP 0
# If the server warn the players before stopping
ENV WARNONSTOP 0
# UID of the user steam
ENV UID 1000
# GID of the user steam
ENV GID 1000

# Install dependencies 
RUN apt-get update &&\ 
    apt-get install -y curl lib32gcc1 lsof git sudo

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i.bkp -e \
	's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
	/etc/sudoers

# Run commands as the steam user
RUN adduser \ 
	--disabled-login \ 
	--shell /bin/bash \ 
	--gecos "" \ 
	steam
# Add to sudo group
RUN usermod -a -G sudo steam

# Copy & rights to folders
COPY run.sh /home/steam/run.sh
COPY user.sh /home/steam/user.sh
COPY crontab /home/steam/crontab
COPY atlasmanager-user.cfg /home/steam/atlasmanager.cfg

RUN touch /root/.bash_profile
RUN chmod 777 /home/steam/run.sh
RUN chmod 777 /home/steam/user.sh
RUN mkdir  /atlas


# We use the git method, because api github has a limit ;)
RUN  git clone https://github.com/BoiseComputer/atlas-server-tools.git /home/steam/atlas-server-tools
WORKDIR /home/steam/atlas-server-tools/
RUN  git checkout $GIT_TAG 
# Install 
WORKDIR /home/steam/atlas-server-tools/tools
RUN chmod +x install.sh 
RUN ./install.sh steam 

# Allow crontab to call atlasmanager
RUN ln -s /usr/local/bin/atlasmanager /usr/bin/atlasmanager

# Define default config file in /etc/atlasmanager
COPY atlasmanager-system.cfg /etc/atlasmanager/atlasmanager.cfg

# Define default config file in /etc/atlasmanager
COPY instance.cfg /etc/atlasmanager/instances/main.cfg

RUN chown steam -R /atlas && chmod 755 -R /atlas

#USER steam 

# download steamcmd
RUN mkdir /home/steam/steamcmd &&\ 
	cd /home/steam/steamcmd &&\ 
	curl http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -vxz 


# First run is on anonymous to download the app
# We can't download from docker hub anymore -_-
#RUN /home/steam/steamcmd/steamcmd.sh +login anonymous +quit

EXPOSE ${STEAMPORT} 32330 ${SERVERPORT}
# Add UDP
EXPOSE ${STEAMPORT}/udp ${SERVERPORT}/udp

VOLUME  /atlas 

# Change the working directory to /arkd
WORKDIR /atlas

# Update game launch the game.
ENTRYPOINT ["/home/steam/user.sh"]
