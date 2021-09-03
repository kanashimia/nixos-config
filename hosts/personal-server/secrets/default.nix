{ config, ... }:

{
  age.secrets = {
    acme-auth.file = ./acme-auth.age;
    chad-password.file = ./chad-password.age;
    rspamd-password = {
      file = ./rspamd-password.age;
      owner = config.services.nginx.user;
      group = config.services.nginx.group;
    };
  };
}
