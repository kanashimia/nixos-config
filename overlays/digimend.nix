inputs: final: prev: {
  linuxPackagesFor = kernel:
    (prev.linuxPackagesFor kernel).extend (lnxfinal: lnxprev: {
      digimend = lnxprev.digimend.overrideAttrs (old: {
        src = inputs.digimend;
        patches = [];
      });
    });
}
