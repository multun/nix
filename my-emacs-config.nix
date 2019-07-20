{ lib, pkgs, stdenv }:
let emacs_python_package = pkgs.python3.withPackages(
      ps: [ps.flake8 ps.pylint]);
in
stdenv.mkDerivation rec {
  name = "my-emacs-config";
  emacs_python = "${emacs_python_package}/bin/python3";
  buildInputs = [ emacs_python_package ];
  emacs_template = ./configs/emacs_template;
  buildCommand = ''
    outfile=$out/.emacs
    install -D -m755 ''${emacs_template} $outfile
    substituteAllInPlace $outfile
  '';
}
