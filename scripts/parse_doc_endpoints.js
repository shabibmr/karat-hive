const fs = require('fs');

const docContent = fs.readFileSync('docs/karat_hive_api_endpoints.md', 'utf8');

// Parse all endpoints documented in section 3 of the markdown file
// Format in md:
// #### 3.X.Y Title
// * **Endpoint**: `POST /v1/auth/otp/request`
// ...
// * **Request Payload**:
// ```json
// { ... }
// ```

const endpointBlocks = [];
const sections = docContent.split(/####\s+\d+\.\d+\.\d+/);

sections.forEach((sec, idx) => {
  if (idx === 0) return; // prelude before first ####
  
  const title = sec.split('\n')[0].trim();
  const endpointMatch = sec.match(/\*\s*\*\*Endpoint\*\*:\s*`([^`]+)`/);
  const endpointsMatch = sec.match(/\*\s*\*\*Endpoints\*\*:\s*`([^`]+)`/);
  const subEndpoints = [...sec.matchAll(/\*\s*\*\*([^*]+)\*\*:\s*`([A-Z]+)\s+([^`]+)`/g)];
  
  let endpoints = [];
  if (endpointMatch) {
    endpoints.push(endpointMatch[1]);
  } else if (endpointsMatch) {
    endpoints.push(endpointsMatch[1]);
  } else if (subEndpoints.length > 0) {
    subEndpoints.forEach(m => endpoints.push(`${m[2]} ${m[3]}`));
  }

  // Extract JSON payload blocks
  const jsonMatches = [...sec.matchAll(/```json\s*([\s\S]*?)\s*```/g)];
  let payload = null;
  // Look for section with Request Payload
  const reqPayloadIdx = sec.indexOf('Request Payload');
  const patchPayloadIdx = sec.indexOf('PATCH Request Payload');
  if (reqPayloadIdx !== -1 || patchPayloadIdx !== -1) {
    const after = sec.substring(reqPayloadIdx !== -1 ? reqPayloadIdx : patchPayloadIdx);
    const jsonMatch = after.match(/```json\s*([\s\S]*?)\s*```/);
    if (jsonMatch) {
      try {
        payload = JSON.parse(jsonMatch[1]);
      } catch (e) {
        payload = jsonMatch[1]; // raw string if comment/unparsed
      }
    }
  }

  endpointBlocks.push({
    title,
    endpoints,
    payload,
    rawText: sec
  });
});

console.log(`Parsed ${endpointBlocks.length} documented endpoint blocks.`);
fs.writeFileSync('parsed_doc_endpoints.json', JSON.stringify(endpointBlocks, null, 2));
