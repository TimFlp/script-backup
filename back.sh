#!/bin/bash

# Paramètres de connexion SSH
remote_user="backupuser"
remote_host="adresse_du_serveur"
remote_dir="/la/ou/on/sauvegarde"

# Répertoires à sauvegarder
directories=(
    "/var/www/html"
    "/var/lib/save"
)

# Boucle sur les répertoires à sauvegarder
for dir in "${directories[@]}"
do
    # Nom du répertoire
    dir_name=$(basename "$dir")

    # Nom du fichier de sauvegarde
    backup_file="${dir_name}_$(date +"%Y%m%d_%H%M%S").tar.gz"

    # Créer une archive tar.gz du répertoire sur le serveur distant
    ssh "$remote_user@$remote_host" "tar -czf '$remote_dir/$backup_file' '$dir'"

    # Vérifier si la création de l'archive a réussi sur le serveur distant
    if [ $? -eq 0 ]; then
        echo "Sauvegarde de $dir créée avec succès sur le serveur distant"
    else
        echo "Échec de la création de la sauvegarde de $dir sur le serveur distant"
        continue
    fi

    # Copier l'archive depuis le serveur distant vers votre machine locale via SCP
    scp "$remote_user@$remote_host:$remote_dir/$backup_file" .

    # Vérifier si la copie a réussi
    if [ $? -eq 0 ]; then
        echo "Sauvegarde de $dir récupérée avec succès sur votre machine locale"
    else
        echo "Échec de la récupération de la sauvegarde de $dir sur votre machine locale"
    fi

    # Supprimer l'archive sur le serveur distant après la copie
    ssh "$remote_user@$remote_host" "rm '$remote_dir/$backup_file'"
done
