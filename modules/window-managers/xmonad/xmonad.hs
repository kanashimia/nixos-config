import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.StackSet
import XMonad.Util.EZConfig
import XMonad.Util.Scratchpad
import XMonad.Hooks.ManageDocks
import XMonad.Actions.Warp
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Run

main = launch $ ewmh $ myKeys myConf

run name app = spawn $ unwords
    [ "systemd-run --user --scope --collect --quiet"
    , "--unit", name ++ "-$(systemd-id128 new)"
    , "systemd-cat --identifier", name, app
    ]

myKeys = flip additionalKeysP
    [ ("M-p", run "search" "@search@")
    , ("M-]", run "chat" "@chat@")
    , ("M-[", run "mail" "@mail@")
    , ("M-S-<Return>", run "terminal" "@terminal@")
    , ("M-<Backspace>", run "browser" "@browser@")
    , ("M-q", restart "xmonad" True)
    , ("<Print>", run "screenshot" "@screenshot@")
    , ("<XF86AudioRaiseVolume>", run "sound" "amixer set Master -q 1%+")
    , ("<XF86AudioLowerVolume>", run "sound" "amixer set Master -q 1%-")
    , ("<XF86AudioMute>", run "sound" "amixer set Master -q toggle")
    ]

isUtility = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_UTILITY"

myManageHook = composeOne
    [ isDialog -?> doCenterFloat
    , isUtility -?> doFloat
    , isFullscreen -?> doFloat
    ]

myConf = def
    { modMask = if "@virtualised@" == "1" then mod1Mask else mod4Mask
    , borderWidth = 1
    , normalBorderColor = "#676e95"
    , focusedBorderColor = "#d5d5e1"
    , manageHook = myManageHook
    , layoutHook = myLayoutHook
    , handleEventHook = fullscreenEventHook
    }

myLayoutHook = smartBorders
    $ toggleLayouts Full
    $ Tall master delta frac
    ||| ThreeColMid master delta frac
    where
    master = 1
    delta = 3/100
    frac = 5/10
