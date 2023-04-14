#!/bin/bash
# This script will update the version in package.json, commit the changes, tag the commit, and publish the new version to npm.

# Exit immediately if a command exits with a non-zero status.
set -e

# prompt the user to select a version if no argument is passed
prompt_version() {
    if [ -z "$1" ]
    then
        while true; do
            read -p "Which version do you want to update? (major/minor/patch): " version
            case $version in
                major|minor|patch ) break;;
                * ) echo "Please enter a valid version option (major/minor/patch).";;
            esac
        done
    else
        # validate the arg passed is one of the valid options
        case $1 in
            major|minor|patch ) version=$1;;
            * ) echo "Invalid version option. Please use major/minor/patch."; exit 1;;
        esac
    fi
}

update_version() {
    while true; do
        # if the comand works, break out of the loop
        if npm version $1; then
            break;
        else
            # redirect standard error to standard output 
            # do a equal match using the * wildcard that match zero or more character in the string. 
            # the [[]] is used for comparison and the $() is used to execute the command
            if [[ $(npm version $1 2>&1) == *"Git working directory not clean."* ]]; then
                echo "\nGit working directory not clean. Please commit any changes before updating the version."
                read -p "Do you want to commit and push the changes? (y/n): " confirm
                case $confirm in
                    y|Y|yes|YES)
                        read -p "Enter a commit message [default: Commit changes before updating version]: " commit_message
                        commit_message=${commit_message:-"Commit changes before updating version"}
                        git add .
                        git commit -m "$commit_message"
                        git push
                        ;;
                    *)
                        echo "Please commit and push any changes before updating the version."
                        exit 1
                        ;;
                esac
            fi
        fi
    done
}

# Confirm if the user wants to tag and release the new version
confirm_release() {
    read -p "Do you want to tag and release version $1? (y/n): " confirm
    case $confirm in
        y|Y|yes|YES)
            # Step 3: Tag the commit
            git tag v$1

            # Step 4: Push changes and tag to remote repository
            git push && git push --tags

            # Step 5: Publish new version to npm
            npm publish
            ;;
        *)
            echo "New version $1 was committed, but not tagged or released."
            ;;
    esac
}

# prompt the user to select a version if no argument is passed
prompt_version $1

# Step 1: Update version in package.json
update_version $version

# Run node js on bash to get the new version
new_version=$(node -p -e "require('./package.json').version")

# Step 2: Commit changes
git add .
git commit -m "Release version $new_version"
git push

confirm_release $new_version
