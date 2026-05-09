#!/data/data/com.termux/files/usr/bin/bash

# Mise à jour du système
pkg update -y && pkg upgrade -y

# Installation des outils de base
pkg install sox -y

# Installation de Python
echo -e "\033[1;34m> Installation de Python...\033[0m"
pkg install python -y || { echo -e "\033[1;31mErreur: Python n'a pas pu être installé !\033[0m"; exit 1; }

# Installation de Git
echo -e "\033[1;36m> Installation de Git...\033[0m"
pkg install git git-lfs -y || { echo -e "\033[1;31mErreur: Git n'a pas pu être installé !\033[0m"; exit 1; }

# Installation de libjpeg-turbo, zlib et libandroid-support
echo -e "\033[1;35m> Installation de libjpeg-turbo, zlib et libandroid-support...\033[0m"
pkg install libjpeg-turbo zlib libandroid-support -y || { echo -e "\033[1;31mErreur: libjpeg-turbo, zlib ou libandroid-support n'ont pas pu être installés !\033[0m"; exit 1; }

# Autorisation de stockage
echo -e "\033[1;33m> Autorisation de stockage...\033[0m"
termux-setup-storage

# Installation des modules Python de base (hors instagrapi)
MODULES="telethon rich pillow termcolor"
FAILED_MODULES=()
SUCCESS_MODULES=()

# Fonction pour installer et vérifier un module Python
install_module() {
    module_with_version=$1
    module=$(echo $module_with_version | cut -d'=' -f1)
    echo -e "\033[1;32mInstallation de $module_with_version...\033[0m"
    pip install --upgrade --no-cache-dir $module_with_version

    python -c "import $module" 2>/dev/null
    if [ $? -eq 0 ]; then
        python - <<END
from rich.console import Console
console = Console()
console.print(":white_check_mark: [bold green]$module installé et importé avec succès[/bold green]")
END
        SUCCESS_MODULES+=("$module_with_version")
    else
        python - <<END
from rich.console import Console
console = Console()
console.print(":x: [bold red]Erreur : $module n'a pas pu être importé après installation ![/bold red]")
END
        FAILED_MODULES+=("$module_with_version")
    fi
}

# Installation et vérification des modules hors instagrapi
for m in $MODULES; do
    install_module $m
done

# Ensuite installation de instagrapi (après libjpeg/zlib)
echo -e "\033[1;34m> Installation de instagrapi...\033[0m"
install_module "instagrapi==2.0"

# Récapitulatif final
if [ ${#FAILED_MODULES[@]} -eq 0 ]; then
    python - <<END
from rich.console import Console
console = Console()
console.print("\n[bold green]Installation terminée. Toutes les dépendances nécessaires sont installées avec succès ![/bold green]\n")
END
else
    python - <<END
from rich.console import Console
console = Console()
console.print("\n[bold yellow]Installation terminée. Les modules suivants n'ont pas pu être importés :[/bold yellow]")
END
    for f in "${FAILED_MODULES[@]}"; do
        echo "- $f"
    done
fi

# Passage dans le dossier TS et exécution
if [ -d "$HOME/TS" ]; then
    cd "$HOME/TS"
    chmod +x *
    if [ -f "./ts.bin" ]; then
        ./ts.bin
    else
        echo -e "\033[1;31mLe fichier ts.bin n'existe pas dans le dossier TS.\033[0m"
    fi
else
    echo -e "\033[1;31mLe dossier TS n'existe pas.\033[0m"
fi
