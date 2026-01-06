FROM ubuntu:24.04

# install openssh-server, sudo, python3 (bắt buộc cho Ansible)
RUN apt-get update && \
    apt-get install -y openssh-server sudo python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Créer l'utilisateur node2 với un home directory
RUN useradd -m -s /bin/bash node2 && \
    echo "node2 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# on configure les mdp
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo 'node2:1234' | chpasswd
RUN echo 'root:1234' | chpasswd

## SSH setup ##
# Création du répertoire de séparation des privilèges
RUN mkdir -p /run/sshd
# IMPORTANT : NE PAS générer les clés pendant le build - elles seront corrompues
# Les clés d'hôte SSH seront générées au démarrage par l'entrypoint
# Copier le fichier de configuration SSH
COPY root.conf /etc/ssh/sshd_config.d/root.conf
# Définir les permissions appropriées (lecture seule cho root)
RUN chmod 600 /etc/ssh/sshd_config.d/root.conf && \
    chown root:root /etc/ssh/sshd_config.d/root.conf
# Copier le script d'entrypoint
COPY entrypoint-node.sh /entrypoint-node.sh
RUN chmod +x /entrypoint-node.sh
# Exposer le port SSH
EXPOSE 22
ENTRYPOINT ["/entrypoint-node.sh"]
