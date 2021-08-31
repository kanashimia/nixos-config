{
  users.users.kanashimia = {
    uid = 1000;
    description = "Kanashimia";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ];
    password = "kanashimia";
  };

  #home-manager.users.kanashimia = {
  #  programs.firefox = {
  #    enable = true;
  #    profiles.kana = {
  #      settings = {
  #        "browser.aboutConfig.showWarning" = false;
  #        "browser.startup.page" = 3;
  #        "network.proxy.type" = 0;
  #        "app.normandy.first_run" = false;
  #        "browser.laterrun.enabled" = false;

  #        "privacy.resistFingerprinting" = true;
  #        "privacy.firstparty.isolate" = true;
  #        "privacy.trackingprotection.enabled" = true;
  #        "browser.send_pings" = false;
  #        "browser.urlbar.speculativeConnect.enabled" = false;
  #        "dom.event.clipboardevents.enabled" = false;
  #        "media.eme.enabled" = false;
  #        "media.gmp-widevinecdm.enabled" = false;
  #        "media.navigator.enabled" = false;
  #        "network.cookie.cookieBehavior" = 1;
  #        "network.http.referer.XOriginPolicy" = 2;
  #        "network.http.referer.XOriginTrimmingPolicy" = 2;
  #        "webgl.disabled" = true;
  #        "browser.sessionstore.privacy_level" = 2;
  #        "beacon.enabled" = false;
  #        "browser.safebrowsing.downloads.remote.enabled" = false;

  #        "network.dns.disablePrefetch" = true;
  #        "network.dns.disablePrefetchFromHTTPS" = true;
  #        "network.predictor.enabled" = false;
  #        "network.predictor.enable-prefetch" = false;
  #        "network.prefetch-next" = false;

  #        "network.IDN_show_punycode" = true;

  #        # "layout.css.font-visibility.level" = 1;
  #        "browser.display.use_document_fonts" = 0;
  #        "dom.security.https_only_mode" = 1;
  #        "extensions.pocket.enabled" = false;
  #        "browser.toolbars.bookmarks.visibility" = "never";
  #      };
  #    };
  #  };
  #};
}
