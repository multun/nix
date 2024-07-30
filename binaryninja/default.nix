# { pname
# , version
# , src
# , stdenv
# , autoPatchelfHook
# , makeWrapper
# , requireFile
# , fetchurl
# , unzip
# , libGL
# , glib
# , fontconfig
# , xorg
# , dbus
# , xkeyboard_config
# , libxkbcommon
# , kerberos
# , nspr
# , alsaLib
# , nss
# , qt6
# , wayland
# }:

# stdenv.mkDerivation rec {
#   inherit pname version src;

#   buildInputs = [
#     autoPatchelfHook makeWrapper
#     unzip
#     libGL stdenv.cc.cc.lib glib fontconfig
#     xorg.libxcb xorg.xcbutilwm xorg.xcbutilkeysyms xorg.xcbutilrenderutil xorg.libXi xorg.libXrender
#     xorg.libXcomposite xorg.libXdamage xorg.libXcursor xorg.libXtst xorg.libXrandr libxkbcommon xorg.xcbutilimage
#     dbus
#     kerberos nspr alsaLib nss
#     wayland
#   ];

#   buildPhase = ":";

#   # this is done by hand for now
#   # TODO: use wrapQtAppsHook
#   dontWrapQtApps = true;

#   autoPatchelfIgnoreMissingDeps = [ "libQt6PrintSupport.so.6" "libQt6Qml.so.6" ];

#   installPhase = ''
#     mkdir -p $out/bin
#     mkdir -p $out/opt/${pname}
#     cp -r * $out/opt/${pname}
#     chmod +x $out/opt/${pname}/binaryninja
#     makeWrapper $out/opt/${pname}/binaryninja \
#           $out/bin/${pname} \
#           --prefix "QT_XKB_CONFIG_ROOT" ":" "${xkeyboard_config}/share/X11/xkb"
#   '';
# }


{ stdenv, autoPatchelfHook, makeWrapper, unzip, libGL, wayland, qt6, wrapQtAppsHook, python310, glib, fontconfig, dbus, version, src }:
stdenv.mkDerivation rec {
  pname = "binaryninja";
  inherit version src;

  buildInputs = [ autoPatchelfHook makeWrapper unzip wayland libGL qt6.full qt6.qtbase python310 stdenv.cc.cc.lib glib fontconfig dbus ];
  nativeBuildInputs = [ wrapQtAppsHook python310.pkgs.wrapPython ];

  dontWrapQtApps = true;
  buildPhase = ":";
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/opt
    cp -r * $out/opt
    chmod +x $out/opt/binaryninja
    makeWrapper $out/opt/binaryninja \
          $out/bin/binaryninja \
          --prefix "QT_QPA_PLATFORM" ":" "wayland"
  '';

  postFixup = ''
    patchelf --debug --add-needed libpython3.so \
      "$out/opt/binaryninja"
  '';


}
