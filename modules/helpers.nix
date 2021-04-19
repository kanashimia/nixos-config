{ pkgs, lib, ... }:

let
mkHelper = name: value: pkgs.writeShellScriptBin name value;

helpers = lib.mapAttrsToList mkHelper {
  repl = ''
    temp="$(mktemp)"
    trap 'rm -f -- "$temp"' EXIT
  
    flakePath="$(dirname -- "$(readlink -f /etc/nixos/flake.nix)")"

    echo "
      let flake = builtins.getFlake \"$flakePath\";
      in { inherit flake; } // flake.nixosConfigurations.$(hostname)
    " > "$temp"
  
    nix repl "$temp"
  '';

  nixos-vm = ''
    temp="$(mktemp -d)"
    trap 'rm -rf -- "$temp"' EXIT
    cd "$temp"
    nixos-rebuild build-vm
    ./result/bin/run-$(hostname)-vm
  '';
};
in
{
  environment.systemPackages = helpers;
}
