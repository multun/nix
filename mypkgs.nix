{ pkgs, ... }:
rec {
  binaryninja = pkgs.callPackage ./binaryninja.nix { };
  myxcwd = pkgs.callPackage ./myxcwd.nix {};
  my-emacs-config = pkgs.callPackage ./my-emacs-config.nix {};
  my-gdbinit = import ./my-gdbinit.nix;
  mdbg = pkgs.callPackage ./mdbg.nix {};
}
