#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token (pass them in as env variables)
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access
function list_users_with_read_access {
    echo "Fetching list of collaborators for $REPO_OWNER/$REPO_NAME..."

    collaborators=$(github_api_get "repos/${REPO_OWNER}/${REPO_NAME}/collaborators" | jq -r '.[].login')

    if [[ -z "$collaborators" ]]; then
        echo "No collaborators found."
        return
    fi

    echo "Users with read access to $REPO_OWNER/$REPO_NAME:"
    for user in $collaborators; do
        permissions=$(github_api_get "repos/${REPO_OWNER}/${REPO_NAME}/collaborators/${user}/permission")
        can_pull=$(echo "$permissions" | jq '.permission == "read" or .permission == "triage" or .permission == "write" or .permission == "admin"')

        if [[ "$can_pull" == "true" ]]; then
            echo "$user"
        fi
    done
}

# Main script
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
