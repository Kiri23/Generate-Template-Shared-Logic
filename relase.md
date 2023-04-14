# How to Release the Project

Follow these steps to release a new version of your project or run sh release.sh to automate the process:

1. Make the changes to your code that you want to include in the new version.
2. Update the version number in the `package.json` file according to the semantic versioning standard (e.g. `1.0.0`, `1.0.1`, `1.1.0`, etc.) using the `npm version <major/minor/patch>` command.
3. Commit the changes to your Git repository.
4. Tag the commit with the new version number using the following command: `git tag <version>`, where `<version>` is the new version number.
5. Push the changes and the tag to the remote Git repository using the following command: `git push && git push --tags`.
6. Publish the new version to npm using the following command: `npm publish`.
