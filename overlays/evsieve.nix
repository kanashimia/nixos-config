inputs: final: prev: {
  evsieve = final.rustPlatform.buildRustPackage rec {
    pname = "evsieve";
    version = "unstable";

    src = inputs.evsieve;
    cargoLock.lockFile = "${inputs.evsieve}/Cargo.lock";

    buildInputs = with final; [
      libevdev
    ];
  };
}
