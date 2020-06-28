package;

import nuget.ContentTarget;

class TestMain {
    static function main() {
        testMatch();
        testExclude();
    }

    static function testExclude() {
        final cases = [
            { file: 'file.js', exclude: null, result: false },
            { file: 'file.js', exclude: 'file.js', result: true },
            { file: 'file.js', exclude: 'styles.css', result: false },
            { file: 'file.js', exclude: 'styles.css;file.js', result: true },
            { file: 'file.js', exclude: 'file.js;styles.css', result: true },
            { file: 'file.js', exclude: 'file.js;styles.css', result: true }
        ];
        for (o in cases) {
            final result = ContentTarget.exclude(o.file, o.exclude);
            if (result != o.result) throw 'FAILED with $result: $o';
        }
    }

    static function testMatch() {
        final cases = [
            { file: 'file.js', src: 'file.js', target: '.', result: 'file.js' },
            { file: 'file.js', src: '*.js', target: '.', result: 'file.js' },
            { file: 'file.js', src: 'file.js', target: 'renamed.js', result: 'renamed.js' },
            { file: 'file.js', src: 'file.js', target: 'content', result: 'content/file.js' },
            { file: 'file.js', src: '*.js', target: 'content', result: 'content/file.js' },
            { file: 'script/file.js', src: 'script/file.js', target: 'content', result: 'content/file.js' },
            { file: 'script/file.js', src: 'script/*.js', target: 'content', result: 'content/file.js' },
            { file: 'script/file.js', src: 'script/file.js', target: 'content', result: 'content/file.js' },
            { file: 'script/file.js', src: 'script/*.js', target: 'content', result: 'content/file.js' },
            { file: 'script/dir/file.js', src: 'script/**/file.js', target: 'content', result: 'content/dir/file.js' },
            { file: 'script/dir/file.js', src: 'script/**/*.js', target: 'content', result: 'content/dir/file.js' }
        ];
        for (o in cases) {
            final result = ContentTarget.match(o.file, o.src, o.target);
            if (result != o.result) throw 'FAILED with $result: $o';
        }
        Sys.println('PASSED');
    }
}
