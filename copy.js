import fs from 'fs-extra';

/**
 * Copies the contents of a directory to another directory.
 * @param {string} sourcePath - The path of the source directory to copy from.
 * @param {string} destinationPath - The path of the destination directory to copy to.
 * @returns {Promise<void>} A Promise that resolves when the copy operation is complete.
 */
async function copyTemplate(sourcePath, destinationPath) {
  try {
    await fs.copy(sourcePath, destinationPath);
  } catch (error) {
    throw new Error(`Error copying template: ${error.message}`);
  }
}

export default copyTemplate;