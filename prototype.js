import main from './index.js';

const { copy, getTemplate } = main;


(async () => {
    const template = await getTemplate();
    console.log(template);
})();