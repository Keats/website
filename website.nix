{ stdenv, rubyLibs }:

stdenv.mkDerivation { 
  name = "we-are-wizards-website";
  phases = "unpackPhase buildPhase installPhase";
  srcs = [ ./. ];
  buildPhase = ''
    export LANG=en_GB.UTF-8
  '';
  installPhase = ''
    mkdir $out
    cp -r ./html $out/
  '';
}
