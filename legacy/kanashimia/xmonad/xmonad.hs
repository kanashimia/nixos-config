import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.StackSet
import XMonad.Util.EZConfig
import XMonad.Util.Scratchpad
import XMonad.Hooks.ManageDocks
import Graphics.X11.ExtraTypes.XF86
import XMonad.Actions.Warp
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageHelpers

main = launch $ ewmh $ additionalKeys myConf myKeys

myKeys = withMod (modMask myConf)
    [ (xK_p, spawn "rofi -show drun -show-icons -m -4")
    , (xK_s, scratchpadSpawnActionCustom "xst -n scratchpad")
    , (xK_Tab, sendMessage NextLayout)
    , (xK_space, sendMessage ToggleLayout)
    , (xK_BackSpace, spawn "firefox")
    , (xK_bracketright, spawn "telegram-desktop")
    , (xK_q, restart "xmonad" True)
    ] ++ withMod noModMask
    [ (xK_Print, spawn "flameshot gui")
    , (xF86XK_AudioRaiseVolume, spawn "amixer set Master 1%+")
    , (xF86XK_AudioLowerVolume, spawn "amixer set Master 1%-")
    , (xF86XK_AudioMute, spawn "amixer set Master toggle")
    ]
    where
    withMod mod = map (\(k, a) -> ((mod, k), a))

isUtility = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_UTILITY"

myFloatHook = composeOne
    [ isDialog -?> doCenterFloat
    , isUtility -?> doFloat
    , className =? "QjackCtl" -?> doFloat
    ]

myConf = def
    { modMask = mod4Mask
    , borderWidth = 1
    , normalBorderColor = "#676e95"
    , focusedBorderColor = "#d5d5e1"
    , terminal = "xst"
    , manageHook = myScratchHook <> myFloatHook
    , layoutHook = myLayoutHook
    }

myLayoutHook = 
    smartBorders
    $ toggleLayouts Full
    $ Tall master delta frac
    ||| ThreeColMid master delta frac
    where
    master = 1
    delta = 3/100
    frac = 5/10

myScratchHook =
    scratchpadManageHook
    $ RationalRect ((1-size)/2) 0 size size
    where
    size = 7/10
