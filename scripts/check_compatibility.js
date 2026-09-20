const fs = require('fs');
const path = require('path');

// Read backend routes
const backendRoutes = JSON.parse(fs.readFileSync('backend_extracted_routes.json'));

// Read table in docs/karat_hive_api_endpoints.md
const doc = fs.readFileSync('docs/karat_hive_api_endpoints.md', 'utf8');

// Parse markdown table in Section 2
const tableRows = [];
const lines = doc.split('\n');
let inTable = false;

for (const line of lines) {
  if (line.includes('| # | HTTP Method | Endpoint URL |')) {
    inTable = true;
    continue;
  }
  if (inTable && line.startsWith('|---')) continue;
  if (inTable && line.startsWith('|')) {
    const cols = line.split('|').map(c => c.trim()).filter(Boolean);
    if (cols.length >= 6) {
      tableRows.push({
        num: cols[0],
        method: cols[1].replace(/`/g, ''),
        url: cols[2].replace(/`/g, ''),
        domain: cols[3],
        roles: cols[4],
        hasBody: cols[5].includes('Yes')
      });
    }
  } else if (inTable && !line.startsWith('|')) {
    inTable = false;
  }
}

console.log(`Parsed ${tableRows.length} table rows from markdown.`);

function normalizePath(p) {
  return p.replace(/\{(\w+)\}/g, ':$1')
          .replace(/:customerId/g, ':id')
          .replace(/:vendorId/g, ':id')
          .replace(/:requestId/g, ':id')
          .replace(/:offerId/g, ':id')
          .replace(/:connectionId/g, ':id')
          .replace(/\/+/g, '/')
          .replace(/\/$/, '');
}

// Compare table rows with backend routes
const results = [];
tableRows.forEach(row => {
  const normDocUrl = normalizePath(row.url);
  const match = backendRoutes.find(br => {
    if (br.httpMethod !== row.method) return false;
    const normBrUrl = normalizePath(br.fullPath);
    return normBrUrl === normDocUrl;
  });

  results.push({
    row,
    found: !!match,
    matchedRoute: match ? `${match.httpMethod} ${match.fullPath} (${match.controller})` : null
  });
});

const notFound = results.filter(r => !r.found);
console.log(`Matched: ${results.length - notFound.length}/${results.length}`);
console.log(`Not found in backend controller scans: ${notFound.length}`);
notFound.forEach(nf => {
  console.log(`  MISSING: ${nf.row.method} ${nf.row.url} (${nf.row.domain})`);
});

fs.writeFileSync('route_matching_results.json', JSON.stringify({ results, notFound }, null, 2));
