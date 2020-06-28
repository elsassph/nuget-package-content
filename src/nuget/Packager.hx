package nuget;

import haxe.crypto.Sha256;
import haxe.DynamicAccess;
import haxe.io.Encoding;
import haxe.io.Bytes;
import haxe.zip.Compress;
import haxe.zip.Writer;
import js.node.Fs;
import js.node.Path;
import npm.Glob;
import nuspec.PackageSpec;
import tink.xml.Structure;

typedef FileSpecEx = {>FileSpec,
    var file: String;
    var data: Bytes;
};

// Based on: https://github.com/NuGet/NuGet.Client/blob/dev/src/NuGet.Core/NuGet.Packaging/PackageCreation/Authoring/PackageBuilder.cs

class Packager {
    static var COMPRESS = false; // doesn't work

    static public function write(nuspecFile: String, version: String, baseDir: String, outDir: String) {
        Sys.println('Loading: $nuspecFile');
        final nuspecRaw = Fs.readFileSync(nuspecFile).toString();
        final nuspecXml = Xml.parse(nuspecRaw);

        Sys.println('Using version: $version');
        updateVersion(nuspecXml, version);

        final nuspec = new Structure<PackageSpec>().read(nuspecXml).sure();
        nuspec.metadata.version = version;

        Sys.println('Resolving files...');
        resolveFiles(nuspec.files, { cwd: baseDir }, [], (files) -> {
            Sys.println('Done: found ${files.length} files, ${getSize(files)} bytes');

            final nuspecPath = Path.basename(nuspecFile);
            final psmdcpPath = 'package/services/metadata/core-properties/${calcPsmdcpName()}.psmdcp';

            Sys.println('Generating manifests...');
            files.push(getPackageManifest(nuspecPath, nuspecXml, version));
            files.push(getOpcPackageProperties(psmdcpPath, nuspec));
            files.push(getRelsManifest(nuspecPath, psmdcpPath));
            files.push(getContentTypesManifest(files));

            Sys.println('Writing package...');
            final outFile = writeZip(nuspec, files, outDir);
            Sys.println('Done: $outFile');
        });
    }

    static function updateVersion(nuspecXml: Xml, version: String) {
        final node = nuspecXml.firstElement().firstElement().elementsNamed('version').next();
        node.firstChild().nodeValue = version;
    }

    static function writeZip(nuspec: PackageSpec, files: Array<FileSpecEx>, outDir: String) {
        final meta = nuspec.metadata;
        final outFile = Path.resolve(outDir, '${meta.id}.${meta.version}.nupkg');
        final zip = new Writer(sys.io.File.write(outFile, true));
        zip.write(Lambda.list(files.map(createZipEntry)));
        return outFile;
    }

    static function createZipEntry(spec: FileSpecEx) {
        final entry = {
            fileName: spec.file,
            fileSize: spec.data.length,
            fileTime: Date.now(),
            compressed: false,
            dataSize: 0,
            data: spec.data,
            crc32: haxe.crypto.Crc32.make(spec.data),
            extraFields: null
        };

        if (COMPRESS) {
            entry.compressed = true;
            entry.data = Compress.run(spec.data, 6);
        }
        return entry;
    }

    static function getContentTypesManifest(files: Array<FileSpecEx>) {
        final map = Lambda.fold(files, (file, acc: DynamicAccess<String>) -> {
            final path = file.file;
            final ext = Path.basename(path).charAt(0) == '.'
                ? Path.basename(path).substr(1)
                : Path.extname(path).substr(1);
            final type = switch (ext) {
                case 'rels': 'application/vnd.openxmlformats-package.relationships+xml';
                case 'psmdcp': 'application/vnd.openxmlformats-package.core-properties+xml';
                default: 'application/octet';
            };
            if (ext != '') acc.set(ext, type);
            return acc;
        }, {});
        final extensions = [
            for (kv in map.keyValueIterator())
                '<Default Extension="${kv.key}" ContentType="${kv.value}" />'
        ];
        final body = '<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  ${extensions.join('\n  ')}
</Types>';
        return createSimpleFile('[Content_Types].xml', body);
    }

    static function getRelsManifest(nuspecPath: String, psmdcpPath: String) {
        final nuspecId = Sha256.encode(nuspecPath).substr(0, 16).toUpperCase();
        final psmdcpId = Sha256.encode(psmdcpPath).substr(0, 16).toUpperCase();
        final body = '<?xml version="1.0" encoding="utf-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Type="http://schemas.microsoft.com/packaging/2010/07/manifest" Target="/${nuspecPath}" Id="R${nuspecId}" />
    <Relationship Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="/${psmdcpPath}" Id="R${psmdcpId}" />
</Relationships>';
        return createSimpleFile('_rels/.rels', body);
    }

    static function getPackageManifest(nuspecPath: String, nuspecXml: Xml, version: String) {
        // keep only metadata node
        final pkg = nuspecXml.firstElement();
        for (node in pkg.elements()) {
            if (node.nodeName != 'metadata') pkg.removeChild(node);
        }
        final body = nuspecXml.toString();
        return createSimpleFile(nuspecPath, body);
    }

    static function getOpcPackageProperties(psmdcpPath: String, nuspec: PackageSpec) {
        final meta = nuspec.metadata;
        final body = '<?xml version="1.0" encoding="utf-8"?>
<coreProperties xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.openxmlformats.org/package/2006/metadata/core-properties">
  <dc:creator>${meta.authors}</dc:creator>
  <dc:description>${meta.description}</dc:description>
  <dc:identifier>${meta.id}</dc:identifier>
  <version>${meta.version}</version>
  <keywords>${meta.tags == null ? '' : meta.tags}</keywords>
  <lastModifiedBy>NuGet, Version=5.3.1.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35;Unix 18.7.0.0;.NET Framework 4.7.2</lastModifiedBy>
</coreProperties>';
        return createSimpleFile(psmdcpPath, body);
    }

    static function createSimpleFile(path: String, body: String) {
        return {
            src: path,
            file: path,
            target: '.',
            exclude: null,
            data: Bytes.ofString(body, Encoding.UTF8)
        };
    }

    static function calcPsmdcpName() {
        return Sha256.encode('${Math.random() * Date.now().getTime()}').substr(0, 32).toLowerCase();
    }

    static function getSize(files: Array<FileSpecEx>) {
        return Lambda.fold(files, (file, size) -> size + file.data.length, 0);
    }

    static function resolveFiles(
        refs: Array<FileSpec>,
        options: GlobOptions,
        result: Array<FileSpecEx>,
        done: (result: Array<FileSpecEx>) -> Void
    ) {
        if (refs.length == 0) {
            return done(result);
        }

        final ref = refs[0];
        Glob.glob(ref.src, options, (err, files) -> {
            if (err) throw err;
            for (file in files) {
                final path = ContentTarget.match(file, ref.src, ref.target);
                if (!ContentTarget.exclude(path, ref.exclude))
                    result.push({
                        src: ref.src,
                        file: path,
                        target: ref.target,
                        data: readFile(options.cwd, file)
                    });
            }
            resolveFiles(refs.slice(1), options, result, done);
        });
    }

    static function readFile(baseDir: String, file: String): Bytes {
        return Fs.readFileSync(Path.resolve(baseDir, file)).hxToBytes();
    }
}
