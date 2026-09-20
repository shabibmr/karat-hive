const fs = require('fs');

const doc = fs.readFileSync('docs/karat_hive_api_endpoints.md', 'utf8');
const schemasText = fs.readFileSync('all_zod_schemas.txt', 'utf8');

console.log('--- ALL ZOD SCHEMAS FROM BACKEND CONTROLLERS ---');
console.log(schemasText.substring(0, 4000));
