self: super: {
  fish = super.fish.override {
    useOperatingSystemEtc = false;
  };
}
