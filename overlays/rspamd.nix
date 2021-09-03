final: prev: {
  rspamd = prev.rspamd.overrideAttrs (old: rec {
    version = "3.0";
    src = final.fetchFromGitHub {
      owner = "rspamd";
      repo = "rspamd";
      rev = version;
      sha256 = "sha256-MXnaQhTDV6ji5634TXA5vvXBlA/SilwM0YYL8DjQL9s=";
    };
  });
}
