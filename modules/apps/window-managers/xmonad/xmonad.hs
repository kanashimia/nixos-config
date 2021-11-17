import XMonad
import XMonad.Actions.Warp
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Magnifier
import XMonad.Layout.NoBorders
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.Util.EZConfig
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.FuzzyMatch

import qualified XMonad.Util.Run as UR
import XMonad.Util.Run.Systemd
import XMonad.Util.NamedScratchpad.Systemd

detectVirt = do
    out <- init <$> UR.runProcessWithInput "systemd-detect-virt" [] ""
    UR.safeSpawn "echo" [ replicate 20 'A' ]
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

myPromptConfig :: XPConfig
myPromptConfig = def
    { position = Top
    , promptBorderWidth = 0
    , defaultText = ""
    , alwaysHighlight = True
    , font = "xft:DejaVu Sans Mono:size=11"
    , searchPredicate = fuzzyMatch
    }

myKeys = flip additionalKeysP $
    [ ("M-S-m", run "thunderbird" [])
    , ("<Print>", run "maim" [])
    , ("M-S-l", runInTerm "journalctl" [ "-f" ])
    , ("M-b", runNS "browser")
    , ("M-c", runNS "telegram")
    , ("M-q", restart "xmonad" True)
    -- , ("M-p", runOrRaisePrompt myPromptConfig)
    , ("M-p", run "rofi" [ "-show", "drun" ])
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
    , NS "telegram" "kotatogram-desktop" [] (className =? "KotatogramDesktop") nonFloating
    ]

isUtility = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_UTILITY"

myManageHook = composeOne
    [ isDialog -?> doCenterFloat
    , isUtility -?> doFloat
    , isFullscreen -?> doFloat
    ]

myLayoutHook = smartBorders $
    maximizeVertical (Tall master delta frac) ||| Full ||| ThreeColMid master delta frac
    where
    master = 1
    delta = 3/100
    frac = 5/10
