import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.StackSet
import XMonad.Util.EZConfig
import XMonad.Util.Scratchpad
import XMonad.Hooks.ManageDocks
import Graphics.X11.ExtraTypes.XF86
import XMonad.Actions.Warp
import XMonad.Layout.NoBorders

main = xmonad $ ewmh $ additionalKeys myConf myKeys

myKeys =
    [ ((myM, xK_p), spawn "rofi -show drun -show-icons -m -4")
    , ((myM, xK_s), scratchpadSpawnActionCustom "st -n scratchpad")
    , ((myM, xK_Tab), sendMessage NextLayout)
    , ((myM, xK_space), sendMessage ToggleLayout)
    , ((myM, xK_BackSpace), spawn "vivaldi")
    , ((myM, xK_bracketright), spawn "Discord")
    , ((myM .|. controlMask, xK_k), sendMessage MirrorExpand)
    , ((myM .|. controlMask, xK_j), sendMessage MirrorShrink)
    , ((myM, xK_backslash), spawn "rofi-power")
    , ((myM, xK_b), sendMessage ToggleStruts)
    , ((noM, xK_Print), spawn "flameshot gui")
    , ((noM, xF86XK_MonBrightnessUp), spawn "brillo -q -A 2 -u 100000")
    , ((noM, xF86XK_MonBrightnessDown), spawn "brillo -q -U 2 -u 100000")
    , ((noM, xF86XK_AudioRaiseVolume), spawn "amixer set Master 1%+")
    , ((noM, xF86XK_AudioLowerVolume), spawn "amixer set Master 1%-")
    , ((noM, xF86XK_AudioMute), spawn "amixer set Master toggle")
    , ((myM, xK_F1), spawn "screen-toggle")
    ]
    where
    myM = modMask myConf
    noM = noModMask

myConf = def
    { modMask = mod4Mask
    , borderWidth = 1
    , normalBorderColor = "#676e95"
    , focusedBorderColor = "#d5d5e1"
    , terminal = "st"
    , manageHook = myScratchHook
    , layoutHook = myLayoutHook
    }

myLayoutHook = avoidStruts
    $ smartBorders
    $ toggleLayouts Full
    $ ResizableTall master delta frac []
    ||| ThreeColMid master delta frac
    where
    master = 1
    delta = 3/100
    frac = 5/10

myScratchHook = scratchpadManageHook
    $ RationalRect ((1-size)/2) 0 size size
    where
    size = 7/10
