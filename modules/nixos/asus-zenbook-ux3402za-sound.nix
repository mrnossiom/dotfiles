# Patches ACPI tables to fix sound issue
#
# Based on
# https://github.com/thor2002ro/asus_zenbook_ux3402za/
# https://gist.github.com/lamperez/d5b385bc0c0c04928211e297a69f32d7
# https://docs.kernel.org/admin-guide/acpi/initrd_table_override.html

{ lib
, pkgs
, ...
}:

with lib;

let
  inherit (pkgs) runCommand acpica-tools cpio;

  ssdt-csc2551-acpi-table-patch = runCommand "ssdt-csc2551" { } ''
    mkdir iasl
    cp ${./ssdt-csc3551.dsl} iasl/ssdt-csc3551.dsl
    ${getExe' acpica-tools "iasl"} -ia iasl/ssdt-csc3551.dsl

    mkdir -p kernel/firmware/acpi
    cp iasl/ssdt-csc3551.aml kernel/firmware/acpi/
    find kernel | ${getExe cpio} -H newc --create > patched-acpi-tables.cpio
    
    cp patched-acpi-tables.cpio $out
  '';
in
{
  config.boot.initrd.prepend = [ (toString ssdt-csc2551-acpi-table-patch) ];
}
