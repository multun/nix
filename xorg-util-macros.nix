{ fetchFromGitLab
, stdenv
, autoconf
, automake
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  pname = "xorg-util-macros";
  version = "1.19.2";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "xorg/util";
    repo = "macros";
    rev = version;
    sha256 = "0hwkrxzfz7m5wdjvmrhkjg8kis378iaqr5n4nhdhkwwhn8x1jn5a";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [ autoconf automake ];

  meta = {
    description = "GNU autoconf macros shared across X.Org projects";
    homepage = https://gitlab.freedesktop.org/xorg/util/macros;
    license = licenses.mit;
    platforms = with platforms; freebsd ++ linux;
  };
}
