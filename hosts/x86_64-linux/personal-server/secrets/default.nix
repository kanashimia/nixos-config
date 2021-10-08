{ inputs, ... }:

{
  imports = [ inputs.agenix.nixosModules.age ];

  age.secrets = {
    acme-auth.file = ./acme-auth.age;
    chad-password.file = ./chad-password.age;
  };
}
