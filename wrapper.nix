with import <nixpkgs> {};
let app = (stdenvNoCC.mkDerivation rec {
  name = "myxcwd";
  script = ./myxcwd;
  buildInputs = [ python3 i3 xorg.xprop ];
  nativeBuildInputs = [ makeWrapper ];
  buildCommand = ''
    outfile=$out/bin/${name}
    outfileunwrapped="$outfile"-unwrapped
    install -D -m755 $script $outfileunwrapped
    patchShebangs  "$outfileunwrapped"
    makeWrapper $outfileunwrapped $outfile --prefix PATH : ${lib.makeBinPath buildInputs}
  '';
    });
in
# Make an environment for nix-shell
stdenv.mkDerivation {
  name = "test-environment";
  buildInputs = [ app ];
}
