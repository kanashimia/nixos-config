import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.StackSet
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Hooks.ManageDocks
import XMonad.Actions.Warp
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Run

main = do
    installSignalHandlers
    launch $ ewmh $ myKeys myConf

run name app args = do
    uniqueId <- init <$> runProcessWithInput "systemd-id128" [ "new" ] []
    safeSpawn "systemd-run" $
        [ "--user", "--scope", "--collect", "--quiet"
        , "--unit", name ++ "-" ++ uniqueId
        , "systemd-cat", "--identifier", name, "--", app
        ] ++ args

runProg name app = run name app []

run' name args = run name name args

runTerm :: [String] -> String -> [String] -> X ()
runTerm options command args = do
    term <- asks (terminal . config)
    safeSpawn term $ options ++ [ "-e", command ] ++ args

runTerm' = runTerm []

myScratchpads =
    [ NS "browser" "chromium" (className =? "Chromium-browser") nonFloating
    , basicNSClass "telegram-desktop" "TelegramDesktop" nonFloating
    ]
    where
    basicNS name = basicNSClass name name
    basicNSClass name classN = NS name name (className =? classN)

runNS = namedScratchpadAction myScratchpads

mapRun cmd = map (run' <$> head <*> tail <$> cmd <$>)
mapRun' cmd = mapRun (\a -> cmd ++ [ a ])

myKeys = flip additionalKeysP $
    [ ("M-p", run' "rofi" [ "-show", "drun" ])
    , ("M-c", runNS "telegram-desktop")
    , ("M-S-m", runProg "mail" "thunderbird")
    , ("M-b", runNS "browser")
    , ("M-S-l", runTerm' "journalctl" [ "-f" ])
    , ("M-q", restart "xmonad" True)
    , ("<Print>", runProg "screenshot" "maim")
    ]
    ++ mapRun' [ "amixer", "set", "Master", "-q" ]
    [ ("<XF86AudioRaiseVolume>", "1%+")
    , ("<XF86AudioLowerVolume>", "1%-")
    , ("<XF86AudioMute>", "toggle")
    ]
    ++ mapRun' [ "mpc" ]
    [ ("<XF86AudioPlay>", "toggle")
    , ("<XF86AudioPrev>", "prev")
    , ("<XF86AudioNext>", "next")
    ]

isUtility = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_UTILITY"

myManageHook = composeOne
    [ isDialog -?> doCenterFloat
    , isUtility -?> doFloat
    , isFullscreen -?> doFloat
    ]

myConf = def
    { modMask = if "@virtualised@" == "1" then mod1Mask else mod4Mask
    , terminal = "alacritty"
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
