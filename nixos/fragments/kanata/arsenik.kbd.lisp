;; This file should be in close to the configs in `github:mrnossiom/zmk-config`

;; Timing variables for tap-hold effects.
(defvar
  ;; The key must be pressed twice in 200ms to enable repetitions.
  tap_timeout 200
  ;; The key must be held 200ms to become a layer shift.
  hold_timeout 200
  ;; Slightly higher value for typing keys, to prevent unexpected hold effect.
  long_hold_timeout 200
)

 
;; no-angle-mod

;; (defsrc
;;   1    2    3    4    5  bspc   6    7    8    9    0
;;   q    w    e    r    t         y    u    i    o    p
;;   a    s    d    f    g         h    j    k    l    ;
;;   z    x    c    v    b    <    n    m    ,    .    /
;;             lalt          spc             ralt
;; )

;; angle-mod: the ISO key (a.k.a. LSGT or 102 key) becomes Z

(defsrc
  1    2    3    4    5   bspc  6    7    8    9    0
  q    w    e    r    t         y    u    i    o    p
  a    s    d    f    g         h    j    k    l    ;
  <    z    x    c    v   b     n    m    ,    .    /
       lmet lalt          spc             ralt rctl
)

;; Base layer: layer-taps under the thumbs + home-row mods on SDF and JKL

(deflayer base
  _    _    _    _    _   _    _    _    _    _    _
  q    w    e    r    t        y    u    i    o    p
  @aa  @ss  @dd  @ff  g        h    @jj  @kk  @ll  @semisft
  z    x    c    v    b   <    n    m    ,    .    /
       ∅    @num          @nav           @sym ∅
)

;; Timing variables are defined in `kanata.kbd` file.

(defalias
  nav (tap-hold $tap_timeout $long_hold_timeout spc (layer-while-held navigation))
  num (tap-hold-press $tap_timeout $hold_timeout bspc (layer-while-held numrow))
  sym (tap-hold-press $tap_timeout $hold_timeout ret (layer-while-held symbols))

  ;; Home-row mods
  aa (tap-hold $tap_timeout $long_hold_timeout a lsft)
  ss (tap-hold $tap_timeout $long_hold_timeout s lalt)
  dd (tap-hold $tap_timeout $long_hold_timeout d lmet)
  ff (tap-hold $tap_timeout $long_hold_timeout f lctl)
  jj (tap-hold $tap_timeout $long_hold_timeout j rctl)
  kk (tap-hold $tap_timeout $long_hold_timeout k rmet)
  ll (tap-hold $tap_timeout $long_hold_timeout l ralt)
  semisft (tap-hold $tap_timeout $long_hold_timeout ; rsft)
)

;; Symbol layer: same as AltGr but enables a NumRow.
;; Concretely this does nothing, just let AltGr as-is for keyboard layouts
;; depending heavily on AltGr, like Bépo or simply Lafayette layouts like
;; Ergo‑L, which already have that layer baked in.
;; Except it adds an NumRow layer.

(deflayer symbols
  AG-1 AG-2 AG-3 AG-4 AG-5 XX     AG-6 AG-7 AG-8 AG-9 AG-0
  AG-q AG-w AG-e AG-r AG-t        AG-y AG-u AG-i AG-o AG-p
  AG-a AG-s AG-d AG-f AG-g        AG-h AG-j AG-k AG-l AG-;
  AG-z AG-x AG-c AG-v AG-b AG-<   AG-n AG-m AG-, AG-. AG-/
       _    _              AG-spc           _    _
)

;; Numrow layer

(deflayer numrow
  _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _         _    _    _    _    _  
  @1   @2   @3   @4   @5        @6   @7   @8   @9   @0
  _    _    _    _    _    _    _    _    _    _    _
       _    _              @nbs           _    _
)

;; Vim-Navigation layer:
;;  - right: Vim-like arrows on HJKL, home/end page up/down, mouse scroll
;;  - left: one-hand shortcuts (Cmd/Ctrl-WASZXCV), Tab/Shift-Tab, prev/next
;;  - top: Super-num (i3/sway) or Alt-num (browser), zoom in/out

;; The `lrld` action stands for "live reload". This will re-parse everything
;; except for linux-dev, i.e. you cannot live reload and switch keyboard devices.

(deflayer navigation
  M-1  M-2  M-3  M-4  M-5  lrld M-6  M-7  M-8  M-9  M-0
  @pad @cls bck  fwd  XX        home pgdn pgup end  @run
  @all @sav S-tab tab XX        lft  down up   rght @fun
  @ndo @cut @cpy @pst XX   _    @mwl @mwd @mwu @mwr XX
       _    del            _              esc  _
)

;; NumPad
(deflayer numpad
  _    _    _    _    _    _    _    _    _    _    _
  XX   home up   end  pgup      @/   @7   @8   @9   XX
  XX   lft  down rght pgdn      @-   @4   @5   @6   @0
  XX   XX   XX   XX   XX   _    @,   @1   @2   @3   @.
       _    @std           @nbs           @std _
)

;; function keys
(deflayer funpad
  XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
  f1   f2   f3   f4   XX        XX   XX   XX   XX   XX
  f5   f6   f7   f8   XX        XX   lctl lalt lmet _
  f9   f10  f11  f12  XX   XX   XX   XX   XX   XX   XX
       _    _               _             _    _
)

(defalias
  std (layer-switch base)
  pad (layer-switch numpad)

  fun (layer-while-held funpad)

  ;; Mouse wheel emulation
  mwu (mwheel-up    50 120)
  mwd (mwheel-down  50 120)
  mwl (mwheel-left  50 120)
  mwr (mwheel-right 50 120)
)

;; Key of the application launcher, mapped to P(nav)
(defalias run M-d)

;; Aliases for `Symbols` and `Navigation` layers
;; Qwerty/Colemak Windows/Linux aliases
;; Works with QWERTY-US, Colemak and others.

;; Navigation layer
(defalias
  all C-a
  sav C-s
  cls C-w
  ndo C-z
  cut C-x
  cpy C-c
  pst C-v

  0 0
  1 1
  2 2
  3 3
  4 4
  5 5
  6 6
  7 7
  8 8
  9 9
  , ,
  . .
)

;; Symbols layer
(defalias
  ^  S-6
  <  S-,
  >  S-.
  $  S-4
  %  S-5
  @  S-2
  &  S-7
  *  S-8
  '  '
  `  `

  {  S-[
  pl S-9
  pr S-0
  }  S-]
  =  =
  \  \
  +  S-=
  -  -
  /  /
  '' S-'

  ~  S-`
  [  [
  ]  ]
  _  S--
  #  S-3
  |  S-\
  !  S-1
  ;  ;
  :  S-;
  ?  S-/
)

;; NumRow layer
(defalias
  s0 S-0
  s1 S-1
  s2 S-2
  s3 S-3
  s4 S-4
  s5 S-5
  s6 S-6
  s7 S-7
  s8 S-8
  s9 S-9
  nbs spc ;; no narrow no-break space in Qwerty

  dk1 XX
  dk2 XX
  dk3 XX
  dk4 XX

  dk5 XX
)
