{ self
, config
, lib
, pkgs
, ...
}:

with lib;

let
  inherit (self.outputs) homeManagerModules;
in
{
  imports = [ homeManagerModules.xcompose ];

  config.programs.xcompose = {
    enable = true;
    includeLocaleCompose = true;
    loadConfigInEnv = false;

    sequences.Multi_key = {
      e.grave = "è";
      e.apostrophe = "é";
      a.grave = "à";
      u.grave = "ù";

      # Lower case [g]reek letters
      g = {
        a = "α";
        b = "β";
        g = "γ";
        d = "δ";
        e = "ε";
        z = "ζ";
        h = "η"; # ?
        # u = "θ"; # ?
        i = "ι";
        k = "κ";
        l = "λ";
        m = "μ";
        n = "ν";
        x = "ξ";
        o = "ο";
        p = "π";
        r = "ρ";
        s = "σ";
        t = "τ";
        u = "υ";
        f = "φ";

      };
      # Lower case [G]reek letters
      G = { };

      # Math
      l.equal = "≤";
      g.equal = "≥";
      s.u.m = "∑";

      # Symbols
      o.o = "∞";

      minus.greater = "→";
      less.minus = "←";
      less.greater.minus = "↔";

      equal.greater = "⇒";
      less.equal = "⇐";
      less.greater.equal = "⇔";

      "0"."0" = "°";
      minus.minus = "—";
    };
  };
}
