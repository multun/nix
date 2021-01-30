{ fetchFromGitLab
, stdenv
, autoconf
, automake
, xorg
, xorg-util-macros
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  pname = "xcb-util-renderutil";
  version = "0.3.9";

  src = builtins.fetchurl {
    url = "https://xcb.freedesktop.org/dist/${pname}-${version}.tar.bz2";
    sha256 = "0nza1csdvvxbmk8vgv8vpmq7q8h05xrw3cfx9lwxd1hjzd47xsf6";
  };

  configureFlags = [ "--disable-static" ];
  makeFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [ autoconf automake ];
  buildInputs = [ xorg.libxcb xorg.xorgproto xorg-util-macros ];

  meta = {
    description = "XCB convenience functions for the Render extension.";
    homepage = https://xcb.freedesktop.org;
    license = licenses.mit;
    platforms = with platforms; freebsd ++ linux;
  };
}
