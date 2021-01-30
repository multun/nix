{ stdenv
, fetchFromGitHub
, pkgconfig
, meson
, ninja
, libunwind
, capstone
, readline
}:

stdenv.mkDerivation rec {
  pname = "mdbg";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "multun";
    repo = pname;
    rev = "31edcc14ee7cbf3f3331cbc43ca324e654b77a5c";
    sha256 = "04gkrrvr1wdc7722ccgbnm3q7ca8hhq44l6w3sj3ashwlhdfhkna";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
  ];

  buildInputs = [
    libunwind
    capstone
    readline
  ];

  meta = with stdenv.lib; {
    description = "A tiny debugger";
    homepage = "https://github.com/multun/mdbg";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ maintainers.multun ];
  };
}
