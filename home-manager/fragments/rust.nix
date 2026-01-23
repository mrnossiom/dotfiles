{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.fragment.rust;

  toml-format = pkgs.formats.toml { };
in
{
  options.local.fragment.rust.enable = lib.mkEnableOption ''
    Rust related
  '';

  config = lib.mkIf cfg.enable {
    # Honor the XDG specification
    home.sessionVariables = {
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    };

    # Add global cargo binaries to PATH
    home.sessionPath = [ "${config.home.sessionVariables.CARGO_HOME}/bin" ];

    # cargo config
    age.secrets.api-crates-io.file = ../../secrets/api-crates-io.age;
    home.file."${config.home.sessionVariables.CARGO_HOME}/config.toml".source =
      let
        clang = lib.getExe pkgs.llvmPackages.clang;
        mold = lib.getExe pkgs.mold-wrapped;
        wild = lib.getExe pkgs.wild;

        get-crates-io-token = pkgs.writeShellScript "get-crates-io-token" "cat ${config.age.secrets.api-crates-io.path}";
      in
      toml-format.generate "cargo-config" {
        registry.global-credential-providers = [ "cargo:token-from-stdout ${get-crates-io-token}" ];

        build = {
          target = "host-tuple";
        };

        source = {
          local-mirror.registry = "sparse+http://local.crates.io:8080/index/";
          # crates-io.replace-with = "local-mirror";
        };

        target = {
          x86_64-unknown-linux-gnu = {
            linker = clang;
            rustflags = [
              "-Clink-arg=--ld-path=${wild}"
              "-Ctarget-cpu=native"
            ];
          };
          x86_64-apple-darwin.rustflags = [ "-Ctarget-cpu=native" ];
          aarch64-apple-darwin.rustflags = [ "-Ctarget-cpu=native" ];
        };

        unstable.gc = true;
      };
  };
}
