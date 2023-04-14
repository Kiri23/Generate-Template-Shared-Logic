#!/bin/bash
# This script will update the version in package.json, commit the changes, tag the commit, and publish the new version to npm.

# Exit immediately if a command exits with a non-zero status.
set -e

# Step 0: Backup package.json
cp package.json package.json.bak

# if an error occurs, run the cleanup function 
trap cleanup ERR INT TERM

cleanup() {
  echo "An error occurred. Reverting package.json to previous version."
  mv package.json.bak package.json
  exit 1
}


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

clean_git() {
    # check if there are any changes to commit
    if git diff-index --quiet HEAD --; then
        echo "No changes to commit. Status is clean."
    else
        case $1 in
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
                 if [[ $2 == "ci" ]]; then
                    #  skip confirmation if the script is run in CI
                    confirm='y'
                    echo "Running in CI. Skipping confirmation."
                else 
                    read -p "Do you want to commit and push the changes? (y/n) [default: y]: " confirm
                    confirm=${confirm:-y}
                fi
                clean_git $confirm
                # run the npm version again, now that we have a clean directory
                npm version $1
            fi
        fi
    done
}

# Confirm if the user wants to tag and release the new version
confirm_release() {
    if [[ $2 == "ci" ]]; then
        #  skip confirmation if the script is run in CI
         confirm='y'
         echo "Running in CI. Skipping confirmation of the release."
    else 
        read -p "Do you want to tag and release version $1? (y/n) [default: y]: " confirm
        confirm=${confirm:-y}
    fi

    case $confirm in
        y|Y|yes|YES)
            # look if there is a tag with the same version
            if git tag -l | grep -q "v$1"; then
                echo "Tag v$1 already exists. Don't need to create a tag since NPM version $1 create one"
            else
                # Step 3: Create a new tag
                git tag -a "v$1" -m "Release version $1"
            fi

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
update_version $version $2

# Run node js on bash to get the new version
new_version=$(node -p -e "require('./package.json').version")


# Step 2: Commit changes
# by some reason if there is nothing to commit, the bash script will exit and will not continue to confirm_release
if git diff-index --quiet HEAD --; then
    echo "No changes to commit. Status is clean. Version $new_version. Continuing to confirm release"
  else 
    git add . && git commit -m "Release version $new_version" && git push;
fi

confirm_release $new_version $2