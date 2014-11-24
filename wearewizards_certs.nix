{ stdenv, fetchgit }:

stdenv.mkDerivation {
  name = "we-are-wizards-website";
  phases = "unpackPhase buildPhase installPhase";
  srcs = fetchgit {
    url = ./certs_etc;
    rev = "HEAD";
    sha256 = "1p0mbjhc04zz0plz4ghh64y0x8xs145pxri70av81fw9q6qx7893";
  };
  buildPhase = ''
    cat wearewizards_io.crt \
        AddTrustExternalCARoot.crt \
        COMODORSAAddTrustCA.crt \
        COMODORSADomainValidationSecureServerCA.crt > bundle.crt
  '';
  installPhase = ''
    mkdir $out
    cp bundle.crt $out/
    cp wearewizards.io.key $out/
  '';
}
