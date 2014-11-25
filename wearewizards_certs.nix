{ stdenv, fetchgit }:

stdenv.mkDerivation {
  name = "we-are-wizards-website";
  phases = "unpackPhase buildPhase installPhase";
  srcs = fetchgit {
    url = ./certs_etc;
    rev = "HEAD";
    sha256 = "1w5vnpniwzf8fd6cza22dqzfas51kj8gv55s6cc3ll62196rsngi";
  };
  buildPhase = ''
    cat wearewizards_io.crt \
        AddTrustExternalCARoot.crt \
        COMODORSAAddTrustCA.crt \
        COMODORSADomainValidationSecureServerCA.crt > bundle.crt
    cat blog_wearewizards_io.crt \
        AddTrustExternalCARoot.crt \
        COMODORSAAddTrustCA.crt \
        COMODORSADomainValidationSecureServerCA.crt > blog_bundle.crt
  '';
  installPhase = ''
    mkdir $out
    cp bundle.crt $out/
    cp wearewizards.io.key $out/
    cp blog_bundle.crt $out/
    cp blog.wearewizards.io.key $out/
  '';
}
