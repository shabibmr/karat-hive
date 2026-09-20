const fs = require('fs');
const path = require('path');

function walk(dir, ext) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat && stat.isDirectory()) results = results.concat(walk(filePath, ext));
    else if (filePath.endsWith(ext) && !filePath.endsWith('.spec.ts')) results.push(filePath);
  });
  return results;
}

const controllers = walk('backend/src', '.controller.ts');
const schemaMap = {};

controllers.forEach(ctrl => {
  const content = fs.readFileSync(ctrl, 'utf8');
  // Find all `const ...Schema = z.object(...)` or `z....`
  const schemaRegex = /(?:const|let|var)\s+([a-zA-Z0-9_]+Schema)\s*=\s*z\.[\s\S]*?(?=;\s*(?:const|let|var|@Controller|export|function|type|interface))/g;
  let m;
  while ((m = schemaRegex.exec(content)) !== null) {
    const schemaName = m[1];
    const schemaBody = m[0].trim();
    schemaMap[`${path.basename(ctrl)} -> ${schemaName}`] = schemaBody;
  }
});

fs.writeFileSync('all_zod_schemas.txt', Object.entries(schemaMap).map(([k, v]) => `=== ${k} ===\n${v}\n`).join('\n'));
console.log(`Extracted ${Object.keys(schemaMap).length} Zod schemas.`);
