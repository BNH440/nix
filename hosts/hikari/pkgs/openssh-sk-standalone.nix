{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "openssh-sk-standalone";
  version = pkgs.openssh.version;
  src = pkgs.openssh.src;
  nativeBuildInputs = with pkgs; [
    autoreconfHook
    pkg-config
  ];
  buildInputs = with pkgs; [
    libfido2
    openssl
    zlib
  ];
  configureFlags = [
    "--with-security-key-standalone"
    "--with-openssl=${pkgs.openssl.dev}"
    "--with-ssl-dir=${pkgs.openssl.dev}"
  ];
  buildPhase = "make sk-libfido2.dylib";
  installPhase = ''
    mkdir -p $out/lib
    cp sk-libfido2.dylib $out/lib/
  '';
}
