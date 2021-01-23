with builtins; rec {
  listHosts = path:
    map (fname: head (match "(.*)\\.nix" fname))
      (attrNames (readDir path));

  listFiles = path:
    map (file: path + "/${file}")
      (filter (x: x != "default.nix")
        (attrNames (readDir path)));

  listFilesInFolders = path:
    concatMap listFiles (listFiles path);
}
