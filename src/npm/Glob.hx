package npm;

// Externs for: https://www.npmjs.com/package/glob

typedef GlobOptions = {
    @:optional var cwd: String;
    @:optional var root: String;
    @:optional var dot: Bool;
    @:optional var nomount: Bool;
    @:optional var mark: Bool;
    @:optional var nosort: Bool;
    @:optional var stat: Bool;
    @:optional var silent: Bool;
    @:optional var strict: Bool;
    @:optional var cache: Dynamic;
    @:optional var statCache: Dynamic;
    @:optional var symlinks: Dynamic;
    @:optional var nounique: Bool;
    @:optional var nonull: Bool;
    @:optional var debug: Bool;
    @:optional var nobrace: Bool;
    @:optional var noglobstar: Bool;
    @:optional var noext: Bool;
    @:optional var nocase: Bool;
    @:optional var nodir: Bool;
    @:optional var matchBase: Bool;
    @:optional var ignore: Array<String>;
    @:optional var follow: Bool;
    @:optional var realpath: Bool;
    @:optional var absolute: Bool;
};

typedef GlobCallback = (err: Dynamic, files: Array<String>) -> Void;

extern class Glob {
    static inline function glob(pattern: String, options: GlobOptions, callback: GlobCallback): Void {
        js.Lib.require('glob')(pattern, options, callback);
    }
}
