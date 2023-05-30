{ lib, stdenv, fetchurl, wrapGAppsHook
, desktop-file-utils, meson, ninja, pkg-config
, sqlite, gdk-pixbuf, glib, gtk4, libadwaita, dbus
, python3, rustPlatform, cargo, rustc
}:

stdenv.mkDerivation rec {
  pname = "furtherance";
  version = "1.7.0";

  src = fetchurl {
    url = "https://github.com/lakoliu/Furtherance/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-zloRZsdLqS21mviqRGPja+1MItU49eYaMr1cit6S26w=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-qLrX3X8wgNrI8G0RgWydVA35cdxcblSUxTKHty+eCds=";
  };

  postPatch = ''
    chmod +x build-aux/cargo.sh
    patchShebangs build-aux/cargo.sh build-aux/meson/postinstall.py
  '';

  nativeBuildInputs = [
    desktop-file-utils meson ninja pkg-config wrapGAppsHook
    cargo
    rustPlatform.cargoSetupHook
    rustc
    python3 # for meson postinstall script
    gtk4 # for gtk-update-icon-cache
    glib # for glib-compile-schemas

  ];
  buildInputs = [ gdk-pixbuf glib gtk4 libadwaita sqlite dbus ];

  meta = with lib; {
    homepage = "https://github.com/lakoliu/Furtherance";
    description = "Track your time without being tracked";
    maintainers = with maintainers; [ multun ];
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
