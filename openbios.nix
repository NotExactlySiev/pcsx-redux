{
  stdenv,
  lib,
  fetchFromGitHub,
  src,
  platforms,
}:
let
  uC-sdk = fetchFromGitHub {
    owner = "grumpycoders";
    repo = "uC-sdk";
    #rev = "86ea3c7019f45ccd4a13503bf7d98a396e8f0193";
    #hash = "sha256-6NmUlOHkRQvCgbATcNxnFrfA2ZWROPYN8Vpd10k6Z2g=";
  };
in stdenv.mkDerivation {
  pname = "openbios";
  version = "0.99test";
  inherit src;

  postUnpack = ''
    rm -rf source/third_party/miniaudio
    cp -r ${miniaudio.out} source/third_party/miniaudio
    chmod -R +w source/third_party/miniaudio
  '';

  nativeBuildInputs = [
    #pkg-config
  ];

  buildInputs = [
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX=mipsel-unknown-none-elf"
  ];

  buildPhase = ''
    make install-openbios
  '';
  
  enableParallelBuilding = true;
  NIX_BUILD_CORES = 2;

  meta = {
    homepage = "https://pcsx-redux.consoledev.net";
    description = "PlayStation 1 open source BIOS";
    inherit platforms;
  };
}
