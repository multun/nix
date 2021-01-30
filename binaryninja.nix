{ pname, version, src, stdenv, autoPatchelfHook, makeWrapper, requireFile, fetchurl, unzip, libGL, glib, fontconfig, xorg, xlibs, dbus, xkeyboard_config, libxkbcommon, kerberos, nspr, alsaLib, nss, qt512}:

stdenv.mkDerivation rec {
  inherit pname version src;

  buildInputs = [ autoPatchelfHook makeWrapper unzip libGL stdenv.cc.cc.lib glib fontconfig xorg.libxcb xlibs.xcbutilwm xlibs.xcbutilkeysyms xlibs.xcbutilrenderutil xlibs.libXi xlibs.libXrender dbus libxkbcommon xlibs.xcbutilimage kerberos nspr xlibs.libXcomposite xlibs.libXdamage xlibs.libXcursor xlibs.libXtst xlibs.libXrandr alsaLib nss qt512.qtwebkit];

  buildPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/opt/${pname}
    cp -r * $out/opt/${pname}
    chmod +x $out/opt/${pname}/binaryninja
    makeWrapper $out/opt/${pname}/binaryninja \
          $out/bin/${pname} \
          --prefix "QT_XKB_CONFIG_ROOT" ":" "${xkeyboard_config}/share/X11/xkb"
  '';
}




# { stdenv
# , autoPatchelfHook
# , makeWrapper
# , fetchurl
# , unzip
# , libGL
# , glib
# , fontconfig
# , xlibs
# , dbus
# , xkeyboard_config
# , libkrb5
# , requireFile
# , libxkbcommon
# , xorg
# , nss
# , nspr
# , alsaLib
# , findutils
# , freetype
# , expat
# , zlib
# , gcc
# }:

# stdenv.mkDerivation rec {
#   name = "binary-ninja";

#   buildInputs = [
#     makeWrapper
#     unzip
#     findutils
#   ];

#   libraryPath = stdenv.lib.makeLibraryPath ([
#     stdenv.cc.cc.lib
#     glib
#     fontconfig
#     xlibs.libXi
#     xlibs.libXrender
#     dbus
#     libkrb5
#     libxkbcommon
#     xorg.libxcb
#     xorg.xcbutilimage
#     xorg.xcbutilwm
#     xorg.xcbutilkeysyms
#     xorg.xcbutilrenderutil
#     xorg.libX11
#     xorg.libXdamage
#     xorg.libXcursor
#     xorg.libXtst
#     xorg.libXrandr
#     xorg.libXcomposite
#     xorg.libXext
#     xorg.libXfixes
#     freetype
#     nss
#     nspr
#     alsaLib
#     zlib
#     expat
#     libGL
#     gcc.cc
#     gcc.libc
#   ]);

#   src = requireFile {
#     name = "BinaryNinja-personal.zip";
#     sha256 = "18mlf7qlzj904p38ag2r1r7cwmqqlcj56ai3yjf47xri1nnp5bjx";
#     url = "https://binary.ninja/recover/";
#   };


#   dontStrip = true;
#   dontPatchELF = true;

#   buildPhase = ''
#     libraryPath="$libraryPath:$out/opt:$out/opt/plugins"
#     echo settings library path as $libraryPath
#     linker=$(cat $NIX_CC/nix-support/dynamic-linker)

#     # patchelf --set-interpreter $linker --set-rpath "$libraryPath" binaryninja
#     # patchelf --set-interpreter $linker --set-rpath "$libraryPath" QtWebEngineProcess
#     # patchelf --set-interpreter $linker --set-rpath "$libraryPath" plugins/scc
#     # patchelf --set-interpreter $linker --set-rpath "$libraryPath" plugins/yasm
#     # find . \( -name '*.so.*' -or -name '*.so' \) ! -name '*.bntl' -type f | tee /dev/stderr | xargs -n1 patchelf --set-rpath "$libraryPath"

#     patchelf --set-interpreter $linker binaryninja
#     patchelf --set-interpreter $linker QtWebEngineProcess
#     patchelf --set-interpreter $linker plugins/scc
#     patchelf --set-interpreter $linker plugins/yasm
#   '';

#   installphase = ''
#     mkdir -p $out/bin
#     mkdir -p $out/opt
#     cp -r * $out/opt
#     chmod +x $out/opt/binaryninja
#     makeWrapper $out/opt/binaryninja \
#           $out/bin/binaryninja \
#           --prefix LD_LIBRARY_PATH : "$libraryPath" \
#           --prefix QT_XKB_CONFIG_ROOT : "${xkeyboard_config}/share/X11/xkb"
#   '';
# }
