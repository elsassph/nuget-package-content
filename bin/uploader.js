#!/usr/bin/env node
const request = require('request');
const fs = require('fs');

const [nupkg, repository, apiKey] = process.argv.slice(2);

if (nupkg === undefined || repository === undefined || apiKey === undefined) {
  console.log("Usage: nuget-upload-package <target nupkg> <nuget repository> <api key>");
  process.exit(1);
}

console.log(`Uploading: ${nupkg}\n       to: ${repository}`)

request({
    url: repository,
    method: 'PUT',
    headers: {
      'X-NuGet-ApiKey': apiKey,
      'X-NuGet-Client-Version': '4.6.2'
    },
    formData: {
      'data': {
        value: fs.createReadStream(nupkg),
        options: {
          fileName: 'package.nupkg'
        }
      }
    }
}, (err, response) => {
  if (err) {
    console.log(err);
    process.exit(1);
  }
  const status = response.statusCode;
  if (status >= 400) {
    console.log(`Refused (${status})`);
    process.exit(1);
  }
  console.log(`Done (${status})`);
  process.exit(0);
});
