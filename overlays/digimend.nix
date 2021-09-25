inputs: final: prev: {
  linuxKernel = prev.linuxKernel // {
    packagesFor = kernel:
      (prev.linuxKernel.packagesFor kernel).extend (_: lnxprev: {
        digimend = lnxprev.digimend.overrideAttrs (old: {
          src = inputs.digimend;
          patches = [];
        });
      });
  };
}
