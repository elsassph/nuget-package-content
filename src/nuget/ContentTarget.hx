package nuget;

import js.node.Path;

class ContentTarget {
    static public function match(file: String, src: String, target: String) {
        final fext = Path.extname(file);
        final text = Path.extname(target);
        // rename
        if (text != '' && text == fext) return target;
        // move root file to location
        if (src.indexOf('/') < 0) {
            if (target == '.') return file;
            return Path.join(target, file);
        }
        // keep glob part
        final star2 = src.indexOf('**');
        if (star2 > 0) {
            return Path.join(target, file.substr(star2 - 1));
        }
        final dir = Path.dirname(src);
        return Path.join(target, file.substr(dir.length + 1));
    }

    static public function exclude(path: String, exclude: String) {
        if (exclude == null) return false;
        final excludes = exclude.split(';');
        final file = path.indexOf('/') > 0 ? Path.basename(path) : path;
        return excludes.contains(file);
    }
}
