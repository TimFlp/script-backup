#!/bin/bash

# Paramètres de connexion SSH
remote_user="backupuser"
remote_host="adresse_du_serveur"

# Répertoires à sauvegarder
files=(
    "/var/www/html/index.html"
    "/var/lib/save"
)

# Création répertoire backup sur machine locale
echo "[*] Création du répertoire de backup daté..."
name=save-$(date +%Y-%m-%d)
mkdir /home/test/backup/$name
chemin_local="/home/test/backup/$name"

# Boucle sur les fichiers à sauvegarder
for file in "${files[@]}"
do
    file_name=$(basename "$file")
    scp "$remote_user@$remote_host:$file_name" "$chemin_local/$file_name"

    # Vérifier si copie réussi
    if [ $? -eq 0 ]; then
        echo "[*] Sauvegarde de $file récupérée avec succès sur votre machine locale..."
    else
        echo "[!] Échec de la récupération de la sauvegarde de $file."
    fi
done

# Zippe le répertoire
echo "[*] Création archive répertoire..."
tar -czvf $name.tar.gz $chemin_local
echo "[*] Suppresion du répertoire..."
rm $chemin_local

# Fini
echo "[*] Procédure de sauvegarde terminée !"
