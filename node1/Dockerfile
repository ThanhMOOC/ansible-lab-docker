FROM ubuntu:24.04

#install openssh-server & sudo
RUN apt-get update && \
    apt-get install openssh-server sudo python3 python3-apt -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Créer l'utilisateur node1 avec un home directory
RUN useradd -m -s /bin/bash node1 && \
    echo "node1 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Tạo thư mục tạm cho Ansible
RUN mkdir -p /root/.ansible/tmp && chmod 777 /root/.ansible/tmp

# on configure les mdp
SHELL ["/bin/bash", "-o", "pipefail", "-c"] 
RUN echo 'node1:1234' | chpasswd
RUN echo 'root:1234' | chpasswd


## SSH setup ##

# Création du répertoire de séparation des privilèges
RUN mkdir -p /run/sshd

# Ces sed sont maintenant inutiles car root.conf fait la même chose
#RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#         sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
#          sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# IMPORTANT : NE PAS générer les clés pendant le build - elles seront corrompues
# Les clés d'hôte SSH seront générées au démarrage par l'entrypoint

# Copier le fichier de configuration SSH
COPY root.conf /etc/ssh/sshd_config.d/root.conf

# Définir les permissions appropriées (lecture seule pour root)
RUN chmod 600 /etc/ssh/sshd_config.d/root.conf && \
    chown root:root /etc/ssh/sshd_config.d/root.conf

# Copier le script d'entrypoint
COPY entrypoint-node.sh /entrypoint-node.sh
RUN chmod +x /entrypoint-node.sh

# Exposer le port SSH
EXPOSE 22
  
ENTRYPOINT ["/entrypoint-node.sh"]