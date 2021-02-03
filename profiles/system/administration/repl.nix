{ pkgs, ... }:

let
repl = pkgs.writeShellScriptBin "repl" ''
  confnix=$(mktemp)
  flakePath=$(dirname $(readlink -f /etc/nixos/flake.nix))
  echo "
    let flake = builtins.getFlake \"$flakePath\";
    in { inherit flake; } // flake.nixosConfigurations.$(hostname)
  " >$confnix
  trap "rm $confnix" EXIT
  nix repl $confnix
'';
in
{
  environment.systemPackages = [ repl ];
}
