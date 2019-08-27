{ pkgs, ... }:
{
  myxcwd = pkgs.callPackage ./myxcwd.nix {};
  my-emacs-config = pkgs.callPackage ./my-emacs-config.nix {};
  my-gdbinit = import ./my-gdbinit.nix;
}
