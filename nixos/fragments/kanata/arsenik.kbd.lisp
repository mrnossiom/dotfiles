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
       _    @num          @nav           @sym _
)

;; Timing variables are defined in `kanata.kbd` file.
(defalias
  nav (tap-hold $tap_timeout $long_hold_timeout spc (layer-while-held navigation))
  num (tap-hold-press $tap_timeout $hold_timeout bspc (layer-while-held numrow))
  sym (tap-hold-press $tap_timeout $hold_timeout ret (layer-while-held symbols))

  semi ;

  ;; Home-row mods
  aa (tap-hold $tap_timeout $long_hold_timeout a lsft)
  ss (tap-hold $tap_timeout $long_hold_timeout s lalt)
  dd (tap-hold $tap_timeout $long_hold_timeout d lmet)
  ff (tap-hold $tap_timeout $long_hold_timeout f lctl)
  jj (tap-hold $tap_timeout $long_hold_timeout j rctl)
  kk (tap-hold $tap_timeout $long_hold_timeout k rmet)
  ll (tap-hold $tap_timeout $long_hold_timeout l ralt)
  semisft (tap-hold $tap_timeout $long_hold_timeout @semi rsft)
)

;; Symbol layer: same as AltGr but enables a NumRow.
(deflayer symbols
  AG-1 AG-2 AG-3 AG-4 AG-5 XX   AG-6 AG-7 AG-8 AG-9 AG-0
  @^   @<   @>   @$   @%        @@   @&   @*   @'   @`
  @{   @pl  @pr  @}   @=        @\   @+   @-   @/   @''
  @~   @[   @]   @_   @#   XX   @|   @!   @;   @:   @?
       XX   XX            spc             XX   XX
)

;; Numrow layer
(deflayer numrow
  XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
  XX   XX   XX   XX   XX        XX   XX   XX   XX   XX  
  @1   @2   @3   @4   @5        @6   @7   @8   @9   @0
  XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
       XX   XX             XX             XX   XX
)

;; Vim-Navigation layer:
;;  - right: Vim-like arrows on HJKL, home/end page up/down, mouse scroll
;;  - left: one-hand shortcuts (Cmd/Ctrl-WASZXCV), Tab/Shift-Tab, prev/next
;;  - top: Super-num (i3/sway) or Alt-num (browser), zoom in/out
(deflayer navigation
  M-1  M-2  M-3   M-4  M-5 XX   M-6  M-7  M-8  M-9  M-0
  @pad @cls bck   fwd  XX       home pgdn pgup end  @run
  @all @sav S-tab tab  XX       lft  down up   rght @fun
  @ndo @cut @cpy  @pst XX  XX   @mwl @mwd @mwu @mwr XX
       XX   del            XX             esc  XX
)

;; NumPad
(deflayer numpad
  XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
  XX   home up   end  pgup      @/   @7   @8   @9   XX
  XX   lft  down rght pgdn      @-   @4   @5   @6   @0
  XX   XX   XX   XX   XX   XX   @,   @1   @2   @3   @.
       XX   @std           XX             @std ∅
)

;; function keys
(deflayer funpad
  XX   XX   XX   XX   XX     XX  XX       XX   XX   XX   XX
  f1   f2   f3   f4   @volup     @brghtup XX   XX   XX   XX
  f5   f6   f7   f8   @voldn     @brghtdn lctl lalt lmet XX
  f9   f10  f11  f12  XX     XX  XX       XX   XX   XX   XX
       XX   @std             XX                @std XX
)

(defalias
  std (layer-switch base)
  pad (layer-switch numpad)
  fun (layer-switch funpad)

  ;; TODO: find how to implement these with XF86 keys
  volup XX
  voldn XX
  brghtup XX
  brghtdn XX

  ;; Mouse wheel emulation
  mwu (mwheel-up    50 120)
  mwd (mwheel-down  50 120)
  mwl (mwheel-left  50 120)
  mwr (mwheel-right 50 120)
)

;; Key of the application launcher, mapped to P(nav)
(defalias run M-d)

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
