{
  self,
  config,
  lib,
  ...
}:

let
  inherit (self.outputs) homeManagerModules;

  cfg = config.local.fragment.compose-key;
in
{
  imports = [ homeManagerModules.xcompose ];

  options.local.fragment.compose-key.enable = lib.mkEnableOption ''
    Compose key related
  '';

  config.programs.xcompose = lib.mkIf cfg.enable {
    enable = true;
    includeLocaleCompose = true;
    loadConfigInEnv = false;

    sequences.Multi_key = {
      e.grave = "è";
      E.grave = "È";
      e.apostrophe = "é";
      E.apostrophe = "É";
      a.grave = "à";
      A.grave = "À";
      u.grave = "ù";
      U.grave = "Ù";
      e.quotedbl = "ë";
      E.quotedbl = "Ë";
      a.quotedbl = "ä";
      A.quotedbl = "Ä";

      quotedbl.quotedbl = "¨";
      apostrophe.apostrophe = "´";

      s.s = "ß";

      # Lower case [g]reek letters
      g = {
        a = "α";
        b = "β";
        g = "γ";
        d = "δ";
        e = "ε";
        z = "ζ";
        h = "η";
        u = "θ";
        i = "ι";
        k = "κ";
        l = "λ";
        m = "μ";
        n = "ν";
        x = "ξ";
        q.o = "ο";
        p = "π";
        r = "ρ";
        s = "σ";
        t = "τ";
        y = "υ";
        f = "φ";
        o = "ω";
      };
      # Upper case [G]reek letters
      G = {
        A = "Α";
        B = "Β";
        G = "Γ";
        D = "Δ";
        E = "Ε";
        Z = "Ζ";
        H = "Η";
        U = "Θ";
        I = "Ι";
        K = "Κ";
        L = "Λ";
        M = "Μ";
        N = "Ν";
        X = "Ξ";
        Q.O = "Ο";
        P = "Π";
        R = "Ρ";
        S = "Σ";
        T = "Τ";
        Y = "Υ";
        F = "Φ";
        O = "Ω";
      };

      # Math
      l.equal = "≤";
      g.equal = "≥";
      s.u.m = "∑";
      asciitilde.asciitilde = "≈";

      # Math double-struck symbols
      M = {
        A = "𝔸";
        B = "𝔹";
        C = "ℂ";
        D = "𝔻";
        E = "𝔼";
        F = "𝔽";
        G = "𝔾";
        H = "ℍ";
        I = "𝕀";
        J = "𝕁";
        K = "𝕂";
        L = "𝕃";
        M = "𝕄";
        N = "ℕ";
        O = "𝕆";
        P = "ℙ";
        Q = "ℚ";
        R = "ℝ";
        S = "𝕊";
        T = "𝕋";
        U = "𝕌";
        V = "𝕍";
        X = "𝕏";
        Y = "𝕐";
        Z = "ℤ";
      };

      # Symbols
      o.o = "∞";
      # Irony point
      question.question = "⸮";

      minus.greater = "→";
      less.minus = "←";

      bar.minus.greater = "↦";
      L.greater = "↳";

      less.greater.minus = "↔";

      equal.greater = "⇒";
      less.equal = "⇐";
      less.greater.equal = "⇔";

      "0"."0" = "°";
      minus.minus = "—";
    };
  };
}
