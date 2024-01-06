# Patches ACPI tables to fix sound issue
#
# Based on
# https://github.com/thor2002ro/asus_zenbook_ux3402za/
# https://gist.github.com/lamperez/d5b385bc0c0c04928211e297a69f32d7
# https://docs.kernel.org/admin-guide/acpi/initrd_table_override.html

{ lib, pkgs, ... }:

let
  inherit (pkgs) stdenv acpica-tools cpio;

  ssdt-csc2551-patched-acpi-table = stdenv.mkDerivation {
    name = "ssdt-csc2551";
    src = ./ssdt-csc3551.dsl;
    buildInputs = [ acpica-tools cpio ];

    unpackPhase = "true";
    buildPhase = ''
      mkdir iasl
      cp $src iasl/ssdt-csc3551.dsl
      iasl -ia iasl/ssdt-csc3551.dsl

      mkdir -p kernel/firmware/acpi
      cp iasl/ssdt-csc3551.aml kernel/firmware/acpi/
      find kernel | cpio -H newc --create > patched-acpi-tables.cpio
    '';

    installPhase = ''
      cp patched-acpi-tables.cpio $out
    '';
  };
in
{
  config = {
    boot.initrd.prepend = [ (toString ssdt-csc2551-patched-acpi-table) ];
  };
}
