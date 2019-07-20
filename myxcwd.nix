{ lib, pkgs, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  name = "myxcwd";
  script = ./myxcwd;
  buildInputs = with pkgs; [ python3 xorg.xprop ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildCommand = ''
    outfile=$out/bin/${name}
    outfileunwrapped="$outfile"-unwrapped
    install -D -m755 $script $outfileunwrapped
    patchShebangs  "$outfileunwrapped"
    makeWrapper $outfileunwrapped $outfile --prefix PATH : ${lib.makeBinPath buildInputs}
  '';
}
