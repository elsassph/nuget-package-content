import js.node.Path;

class Main {
    static function main() {
        final args = Sys.args();
        final nuspecFile = args[0];
        if (nuspecFile == null) {
            throw 'Usage: nuget-package-content <target> <version> [<output dir>]';
        }
        final version = args[1];
        if (version == null) {
            throw 'Missing argument: package version';
        }
        final baseDir = args[2] != null ? args[2] : Path.dirname(nuspecFile);

        nuget.Packager.write(nuspecFile, version, baseDir, Sys.getCwd());
    }
}
