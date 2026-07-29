{
  programs.chromium = {
    enable = true;
    extraOpts = {
      "DnsOverHttpsMode" = "secure";
      "DnsOverHttpsTemplates" = "https://dns.cloudflare.com/dns-query";
      "PasswordManagerEnabled" = false;
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
    };
  };
}
