self: super: {
  vivaldi = super.vivaldi.override {
    proprietaryCodecs = true;
    enableWidevine = true;
  };
}
