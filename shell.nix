with import <nixpkgs> {
  config = {
    packageOverrides = pkgs: with pkgs; {
      llvmPackages = llvmPackages_13;
      clang = clang_13;
      lld = lld_13;
      jdk = if stdenv.isDarwin then jdk11_headless else graalvm11-ce;
      protobuf = protobuf3_15; # required by firrtl
    };
  };
};

let
  clang-multiple-target =
    pkgs.writeScriptBin "clang" ''
      #!${pkgs.bash}/bin/bash
      if [[ "$*" == *--target=riscv64* ]]; then
        # works partially, namely no ld
        ${pkgs.clang.cc}/bin/clang --target=riscv64 $@
      else
        # works fully
        ${pkgs.clang}/bin/clang $@
      fi
    '';
  clangpp-multiple-target =
    pkgs.writeScriptBin "clang++" ''
      #!${pkgs.bash}/bin/bash
      if [[ "$*" == *--target=riscv64* ]]; then
        # works partially, namely no ld
        ${pkgs.clang.cc}/bin/clang++ --target=riscv64 $@
      else
        # works fully
        ${pkgs.clang}/bin/clang++ $@
      fi
    '';
  cpp-multiple-target = pkgs.writeScriptBin "cpp" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.clang}/bin/cpp $@
  '';
in pkgs.callPackage (
  {
    mkShell,
    jdk,
    gnumake, git, mill, wget, parallel, dtc, protobuf, antlr4,
    llvmPackages, clang, lld, verilator, cmake, ninja, strace
  }:

  mkShell {
    name = "sequencer-playground";
    depsBuildBuild = [
      jdk gnumake git mill wget parallel dtc protobuf antlr4
      verilator cmake ninja
      llvmPackages.llvm lld

      clang-multiple-target
      clangpp-multiple-target
      cpp-multiple-target
    ];
    shellHook = ''
      unset CC
      unset CXX
      unset LD
    '';
  }
) {}
