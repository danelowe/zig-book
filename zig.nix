# Also see "github:mitchellh/zig-overlay"; 
# Creating a static package here for simplicity.
{ fetchurl, stdenv, callPackage, lib }:
let
  version = "0.14.0";
  url = "https://ziglang.org/download/0.14.0/zig-macos-aarch64-0.14.0.tar.xz";
  sha256 = "sha256-tx5LfEtL6ZU2V4d/f55vfuiRFMcW2nwHD0ojgiDpXX4=";
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;

  pname = "zig";
  src = fetchurl { inherit url sha256; };
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  installPhase = ''
    mkdir -p $out/{doc,bin,lib}
    [ -d docs ] && cp -r docs/* $out/doc
    [ -d doc ] && cp -r doc/* $out/doc
    cp -r lib/* $out/lib
    cp zig $out/bin/zig
  '';
  passthru = {
    hook = callPackage ./zig/hook.nix { zig = finalAttrs.finalPackage; };
  };
  meta = {
    description = "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software";
    homepage = "https://ziglang.org/";
    changelog = "https://ziglang.org/download/${finalAttrs.version}/release-notes.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ andrewrk ] ++ lib.teams.zig.members;
    mainProgram = "zig";
    platforms = lib.platforms.unix;
  };
})

