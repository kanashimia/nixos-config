{
  listHosts = with builtins; path:
    map (fname: head (match "(.*)\\.nix" fname))
      (attrNames (readDir path));
  listFiles = with builtins; path:
    map (fname: path + "/${fname}")
      (attrNames (readDir path));
}
