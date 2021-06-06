with builtins;

let
keysUrl = "https://github.com/kanashimia.keys";

keys = filter isString (split "\n" (readFile (fetchurl keysUrl)));

module = import ./module.nix;
#secrets = mapAttrs (n: v: { publicKeys = keys; }) module.age.secrets;

secrets = listToAttrs (map mkSecret (attrValues module.age.secrets));

mkSecret = attr: {
  name = baseNameOf attr.file;
  value.publicKeys = keys;
};
in
secrets
