FROM ubuntu:24.04

#Dockerfile de ansible-img

#install openssh-server & sudo
RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    openssh-client \
    sshpass \
    sudo sshpass   \
    iputils-ping   \
    vim \
    procps \
    ansible \
    docker.io \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Créer l'utilisateur ansible-server avec un home directory
RUN useradd -m -s /bin/bash ansible-server && \
    echo "ansible-server ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# on configure les mdp
SHELL ["/bin/bash", "-o", "pipefail", "-c"] 
RUN echo 'ansible-server:1234' | chpasswd
RUN echo 'root:1234' | chpasswd


## SSH setup ##
# Créer le répertoire .ssh avec les bonnes permissions
RUN mkdir -p /home/ansible-server/.ssh && \
    chown ansible-server:ansible-server /home/ansible-server/.ssh && \
    chmod 700 /home/ansible-server/.ssh

# Copier la clé publique SSH
COPY --chown=ansible-server:ansible-server id_ed25519.pub /home/ansible-server/.ssh/authorized_keys

# Définir les permissions correctes pour authorized_keys
RUN chmod 600 /home/ansible-server/.ssh/authorized_keys

# Création du répertoire de séparation des privilèges
RUN mkdir -p /run/sshd

# Configurer SSH (optionnel mais recommandé)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# IMPORTANT : Générer les clés d'hôte SSH
#RUN ssh-keygen -A
# NE PAS générer les clés pendant le build - elles seront corrompues
# Les clés seront générées au démarrage par l'entrypoint

# Copier le script d'entrypoint-server
COPY entrypoint-server.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Exposer le port SSH
EXPOSE 22

## switch to ansible-server
#USER  ansible-server
#WORKDIR /home/ansible-server

#CMD ["/usr/sbin/sshd", "-D"]
# Utiliser l'entrypoint
ENTRYPOINT ["/entrypoint.sh"]