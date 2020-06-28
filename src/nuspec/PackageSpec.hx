package nuspec;

// Based on: https://docs.microsoft.com/en-us/nuget/reference/nuspec

// (only useful metas referenced here)
typedef MetadataSpec = {
    var id: String;
    var version: String;
    var description: String;
    var authors: String;
    @:optional var tags: String;
};

typedef FileSpec = {
    @:attr var src: String;
    @:attr var target: String;
    @:optional @:attr var exclude: String;
}

typedef PackageSpec = {
    var metadata: MetadataSpec;
    var files: Array<FileSpec>;
};
