#{ lib, ... }:

# let
#  func = dir:
#    lib.mapAttrs' (name: type:
#      lib.nameValuePair (lib.removeSuffix ".age" name) { file = dir + "/${name}"; }
#    ) (
#      lib.filterAttrs (name: type:
#        type == "regular" && hasSuffix ".age" name
#      ) (builtins.readDir dir)
#    );
# in
{
  age.secrets.acme-auth.file = ./acme-auth.age;
  age.secrets.chad-password.file = ./chad-password.age;
}
