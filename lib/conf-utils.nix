rec {
  listHosts = with builtins; path:
    map (fname: head (match "(.*)\\.nix" fname))
      (attrNames (readDir path));

  listFiles = with builtins; path:
    map (file: path + "/${file}")
      (filter (x: x != "default.nix")
        (attrNames (readDir path)));

  listFilesInFolders = with builtins; path:
    concatMap listFiles (listFiles path);
}
