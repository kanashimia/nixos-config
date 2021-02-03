{ pkgs, ... }:

let
setToExports = set:
  pkgs.lib.concatStringsSep "\n"
    (pkgs.lib.mapAttrsToList (a: b: "export ${a}=${b}") set);
in
{
  wrap = name: set: let
    package = pkgs.${name};
    exports = setToExports set;
    src = pkgs.writeShellScriptBin name ''
      ${exports}
      exec ${package}/bin/${name} "$@"
    '';
  in pkgs.symlinkJoin {
    inherit name;
    paths = [
      package
    ];
  };
}
