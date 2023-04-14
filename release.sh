#!/bin/bash

# prompt the user to select a version if no argument is passed
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

# Step 1: Update version in package.json
npm version $version
# Run node js on bash to get the new version
new_version=$(node -p -e "require('./package.json').version")

# Step 2: Commit changes
git add .
git commit -m "Release version $new_version"
git push

# Confirm if the user wants to tag and release the new version
read -p "Do you want to tag and release version $new_version? (y/n): " confirm
case $confirm in
    y|Y|yes|YES)
        # Step 3: Tag the commit
        git tag v$new_version

        # Step 4: Push changes and tag to remote repository
        git push && git push --tags

        # Step 5: Publish new version to npm
        npm publish
        ;;
    *)
        echo "New version $new_version was committed, but not tagged or released."
        ;;
esac
