import fs from 'fs';
import path from 'path';

const getTemplates = async () => {
  const templatesDirectory = "/Users/christiannogueras/Documents/Personal projects/templates"
  const templateFolders = await fs.promises.readdir(templatesDirectory);

  const templates = await Promise.all(templateFolders.map((folderName) => getTemplateData(folderName, templatesDirectory)));

  // if the template is null, it means it's not a directory, so we filter it out.
  return templates.filter((template) => template !== null);
}

const getTemplateData = async (folderName, templatesDirectory) => {
  const folderPath = path.join(templatesDirectory, folderName);
  const stat = await fs.promises.stat(folderPath);

  if (!stat.isDirectory()) {
    return null;
  }

  return {
    name: folderName,
    folder: folderPath,
  };
}


export default getTemplates;
