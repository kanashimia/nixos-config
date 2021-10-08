{
  programs.chromium = {
    enable = true;
    extraOpts = {
      "PasswordManagerEnabled" = false;
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      "BrowserThemeColor" = "#eaeaea";
    };
  };
}
