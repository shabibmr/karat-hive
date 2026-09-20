const fs = require('fs');
const path = require('path');

function walk(dir, ext) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat && stat.isDirectory()) results = results.concat(walk(filePath, ext));
    else if (filePath.endsWith(ext)) results.push(filePath);
  });
  return results;
}

const controllers = walk('backend/src', '.controller.ts');
const routes = [];

controllers.forEach(ctrlPath => {
  const content = fs.readFileSync(ctrlPath, 'utf8');
  
  const ctrlMatch = content.match(/@Controller\s*\(\s*['"]?(.*?)['"]?\s*\)/);
  let prefix = ctrlMatch ? ctrlMatch[1] : '';
  prefix = prefix.replace(/^\/+|\/+$/g, '');
  
  const lines = content.split('\n');
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const match = line.match(/@(Get|Post|Patch|Put|Delete)\s*\(\s*(?:['"](.*?)['"])?\s*\)/);
    if (match) {
      const httpMethod = match[1].toUpperCase();
      let subPath = match[2] || '';
      subPath = subPath.replace(/^\/+|\/+$/g, '');
      
      let fullPath = '/' + (prefix ? prefix + (subPath ? '/' + subPath : '') : subPath);
      fullPath = fullPath.replace(/\/+/g, '/');
      if (fullPath === '') fullPath = '/';

      // Look ahead for the method signature and @Body
      let methodSig = '';
      let j = i + 1;
      while (j < lines.length && !lines[j].includes('{')) {
        methodSig += lines[j] + ' ';
        j++;
      }
      if (j < lines.length) methodSig += lines[j];
      
      routes.push({
        controller: path.basename(ctrlPath),
        httpMethod,
        fullPath,
        sig: methodSig.replace(/\s+/g, ' ').trim()
      });
    }
  }
});

fs.writeFileSync('scratch_routes.json', JSON.stringify(routes, null, 2));
console.log(`Extracted ${routes.length} backend routes.`);
