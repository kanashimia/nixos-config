{
  environment.variables = rec {
    PAGER = "less";
    LESS = "-FRSXMKi --mouse --wheel-lines=3";
    SYSTEMD_LESS = LESS;
  };
}
