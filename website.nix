{ stdenv, rubyLibs }:

stdenv.mkDerivation { 
  name = "we-are-wizards-website";
  phases = "unpackPhase buildPhase installPhase";
  buildInputs = [ rubyLibs.sass ];
  srcs = [ ./. ];
  buildPhase = ''
    export LANG=en_GB.UTF-8
    sass --style compressed ./scss/app.scss > ./html/app.css
  '';
  installPhase = ''
    mkdir $out
    cp -r ./html $out/
  '';
}