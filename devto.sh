#!/bin/bash

# ======================================
# Initialisation
# ======================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/config.env"
source "$SCRIPT_DIR/functions/articles.sh"
source "$SCRIPT_DIR/functions/comments.sh"
source "$SCRIPT_DIR/functions/tags.sh"



# ======================================
# Couleurs ANSI
# ======================================

RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"

# ======================================
# Fonctions utilitaires
# ======================================

pause() {
  read -rp "$(echo -e "${YELLOW}Appuyez sur Entrée pour continuer...${RESET}")"
}

header() {
  clear
  echo -e "${BLUE}${BOLD}"
  echo "======================================"
  echo "     MENU INTERACTIF API DEV.TO"
  echo "======================================"
  echo -e "${RESET}"
}

success() {
  echo -e "${GREEN}$1${RESET}"
}

error() {
  echo -e "${RED}$1${RESET}"
}

# ======================================
# Menu principal
# ======================================

while true; do
  header
  echo -e "${YELLOW}1)${RESET} Lister les articles publics"
  echo -e "${YELLOW}2)${RESET} Voir MES articles (ID)"
  echo -e "${YELLOW}3)${RESET} Voir un article (ID)"
  echo -e "${YELLOW}4)${RESET} Publier un article"
  echo -e "${YELLOW}5)${RESET} Modifier un article (titre + body)"
  echo -e "${YELLOW}6)${RESET} Supprimer un article"
  echo -e "${YELLOW}7)${RESET} Voir les commentaires d’un article"
  echo -e "${YELLOW}8)${RESET} Lister les tags"
  echo -e "${YELLOW}0)${RESET} Quitter"
  echo "--------------------------------------"

  read -rp "Votre choix : " choice

  case "$choice" in

    1)
      header
      get_articles | jq '.[] | {id, title, published_at}'
      pause
      ;;

    2)
      header
      success "Mes articles :"
      get_my_articles | jq '.[] | {
        id: .id,
        title: .title,
        published: .published,
        created_at: .created_at
      }'
      pause
      ;;

    3)
      read -rp "ID de l'article : " article_id
      header
      get_single_article "$article_id"
      pause
      ;;

    4)
      read -rp "Titre : " title
      read -rp "Tags (ex: bash,linux,api) : " tags
      echo -e "${YELLOW}Contenu (CTRL+D pour terminer) :${RESET}"
      body=$(</dev/stdin)

      header
      response=$(publish_article "$title" "$body" "$tags")
      echo "$response" | jq

      article_id=$(echo "$response" | jq -r '.id')
      [[ "$article_id" != "null" ]] && success "Article créé avec l'ID : $article_id"

      pause
      ;;

    5)
      read -rp "ID de l'article à modifier : " article_id
      read -rp "Nouveau titre : " new_title
      echo -e "${YELLOW}Nouveau contenu (CTRL+D pour terminer) :${RESET}"
      new_body=$(</dev/stdin)

      header
      update_article "$article_id" "$new_title" "$new_body" | jq
      success "Article mis à jour."
      pause
      ;;

    6)
      read -rp "ID de l'article à supprimer : " article_id
      read -rp "Confirmer suppression ? (y/n) : " confirm

      if [[ "$confirm" == "y" ]]; then
        delete_article "$article_id"
        success "Article supprimé."
      else
        error "Suppression annulée."
      fi

      pause
      ;;

    7)
      read -rp "ID de l'article : " article_id
      read -rp "Nombre de commentaires à afficher : " limit

      header
      get_comments "$article_id" | jq ".[0:$limit] | .[] | {
        user: .user.username,
        body_html
      }"
      pause
      ;;

    8)
      header
      get_tags | jq '.[] | {name, popularity_score}'
      pause
      ;;

    0)
      success "tchao"
      exit 0
      ;;

    *)
      error "Choix invalide."
      sleep 1
      ;;
  esac
done
