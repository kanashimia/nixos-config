import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageDocks
import XMonad.Actions.Warp
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageHelpers

import qualified XMonad.Util.Run as UR
import XMonad.Util.Run.Systemd
import XMonad.Util.NamedScratchpad.Systemd

detectVirt = do
    out <- init <$> UR.runProcessWithInput "systemd-detect-virt" [] ""
    pure $ out /= "none"

main = do
    installSignalHandlers
    isVirt <- detectVirt
    launch $ ewmh $ myKeys $ myConf isVirt

myConf isVirt = def
    { modMask = if isVirt then mod1Mask else mod4Mask
    , terminal = "@terminal@"
    , borderWidth = 1
    , normalBorderColor = "#676e95"
    , focusedBorderColor = "#d5d5e1"
    , manageHook = myManageHook
    , layoutHook = myLayoutHook
    , handleEventHook = fullscreenEventHook
    }

myKeys = flip additionalKeysP $
    [ ("M-p", run "rofi" [ "-show", "drun" ])
    , ("M-S-m", run "thunderbird" [])
    , ("<Print>", run "maim" [])
    , ("M-S-l", runInTerm "journalctl" [ "-f" ])
    , ("M-b", runNS "browser")
    , ("M-c", runNS "telegram")
    , ("M-q", restart "xmonad" True)
    ]
    ++ mapKeysRun "amixer" [ "set", "Master", "-q" ]
    [ ("<XF86AudioRaiseVolume>", "1%+")
    , ("<XF86AudioLowerVolume>", "1%-")
    , ("<XF86AudioMute>", "toggle")
    ]
    ++ mapKeysRun "mpc" []
    [ ("<XF86AudioPlay>", "toggle")
    , ("<XF86AudioPrev>", "prev")
    , ("<XF86AudioNext>", "next")
    ]
    where
    runNS = namedScratchpadAction myScratchpads
    mapKeysRun cmd args = map $ \(key, arg) -> (key, run cmd $ args ++ [ arg ])

myScratchpads :: NamedScratchpads
myScratchpads =
    [ NS "browser" "chromium" [] (className =? "Chromium-browser") nonFloating
    , NS "telegram" "telegram-desktop" [] (className =? "TelegramDesktop") nonFloating
    ]

isUtility = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_UTILITY"

myManageHook = composeOne
    [ isDialog -?> doCenterFloat
    , isUtility -?> doFloat
    , isFullscreen -?> doFloat
    ]

myLayoutHook = smartBorders
    $ toggleLayouts Full
    $ Tall master delta frac
    ||| ThreeColMid master delta frac
    where
    master = 1
    delta = 3/100
    frac = 5/10
