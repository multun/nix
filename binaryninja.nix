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
