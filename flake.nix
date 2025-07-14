{
  description = "Escape game sound system";

  outputs = _: {
    nixosModules = {
      control = import ./control.nix;
      escape = import ./escape.nix;
    };
  };
}
