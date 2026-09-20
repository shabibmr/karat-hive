const fs = require('fs');
const path = require('path');

// 1. Read all controller files
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
console.log(`Analyzing ${controllers.length} active controllers...`);

const backendRoutes = [];

controllers.forEach(ctrlFile => {
  const code = fs.readFileSync(ctrlFile, 'utf8');
  
  // Extract controller path
  const ctrlMatch = code.match(/@Controller\s*\(\s*(?:['"](.*?)['"])?\s*\)/);
  let prefix = ctrlMatch && ctrlMatch[1] ? ctrlMatch[1] : '';
  prefix = prefix.replace(/^\/+|\/+$/g, '');

  // Extract handlers
  // Find each method with @Get, @Post, @Patch, @Put, @Delete
  const methodRegex = /@(Get|Post|Patch|Put|Delete)\s*\(\s*(?:['"](.*?)['"])?\s*\)([\s\S]*?)(?:async\s+|public\s+)?(\w+)\s*\(([\s\S]*?)\)\s*(?::\s*[\w<>\[\]\s,|]+)?\s*\{/g;
  
  let m;
  while ((m = methodRegex.exec(code)) !== null) {
    const httpMethod = m[1].toUpperCase();
    let routeSubPath = m[2] || '';
    routeSubPath = routeSubPath.replace(/^\/+|\/+$/g, '');
    
    let fullPath = '/' + (prefix ? prefix + (routeSubPath ? '/' + routeSubPath : '') : routeSubPath);
    fullPath = fullPath.replace(/\/+/g, '/');
    if (fullPath === '') fullPath = '/';

    const handlerName = m[4];
    const paramsStr = m[5];

    // Find Body schema or type
    // Look for @Body(new ZodValidationPipe(schema)) or @Body() body: Type
    let bodyInfo = null;
    const bodyMatch = paramsStr.match(/@Body\s*\(([^)]*)\)\s*(\w+)(?:\s*:\s*([^,)]+))?/);
    if (bodyMatch) {
      const pipeArg = bodyMatch[1].trim();
      const paramName = bodyMatch[2].trim();
      const typeName = bodyMatch[3] ? bodyMatch[3].trim() : '';
      bodyInfo = {
        pipeArg,
        paramName,
        typeName
      };
    }

    // Path params
    const pathParamMatches = [...paramsStr.matchAll(/@Param\s*\(\s*['"]?(\w+)['"]?\s*\)/g)].map(x => x[1]);

    // Query params
    const queryParamMatches = [...paramsStr.matchAll(/@Query\s*\(\s*(?:['"]?(\w+)['"]?)?\s*(?:,\s*([^)]+))?\)/g)].map(x => x[1] || 'all');

    backendRoutes.push({
      controller: path.basename(ctrlFile),
      httpMethod,
      fullPath,
      handlerName,
      bodyInfo,
      pathParamMatches,
      queryParamMatches
    });
  }
});

console.log(`Found ${backendRoutes.length} backend endpoints.`);
fs.writeFileSync('backend_extracted_routes.json', JSON.stringify(backendRoutes, null, 2));
