# Nuget static content packager

A minimalistic, node-based, standalone nuget packager for static content files,
based on the sources of the [NuGet client](https://github.com/NuGet/NuGet.Client).

*This tool should NOT be used for packaging .NET applications*

## Rationale

For those who want to create simple nuget packages with static files,
and who would like to avoid running .NET/Core and the official nuget client.

The tool takes a `.nuspec` refering to static content files, and creates a
hopefully valid `.nupkg` from that.

## Usage

Usage: `nuget-package-content <target> <version> [<output directory>]`

```bash
npm install nuget-package-content
npx nuget-package-content MyApp.nuspec 1.2.3
```

## Limitations

What is NOT supported:

- Licenses,
- Replacement tokens,
- Metadata contentFiles,
- Dependencies,
- Assembly/Framework references.

What is supported: just files.

- Target `.nuspec` should be at the root of the folder containing the content files,
- Glob patterns are supported (using npm `glob` package for matching),
- Best effort to support file's `target` specification,
- File's `exclude` currently only tests exact file names.

Example:

```xml
<files>
    <file src="index.html" target="." />
    <file src="asset/**/*.*" target="assets" exclude="favicon.ico" />
</files>
```

## License: ISC

Copyright 2020, Philippe Elsass

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
