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
    dirs <- getDirs
    launch (ewmh $ myKeys myConf) dirs

run name app args = do
    uniqueId <- init <$> runProcessWithInput "systemd-id128" [ "new" ] []
    safeSpawn "systemd-run" $
        [ "--user", "--scope", "--collect", "--quiet"
        , "--unit", name ++ "-" ++ uniqueId
        , "systemd-cat", "--identifier", name, "--", app
        ] ++ args

runProg name app = run name app []

runTerm :: [String] -> String -> [String] -> X ()
runTerm options command args = do
    term <- asks (terminal . config)
    safeSpawn term $ options ++ [ "-e", command ] ++ args

runTerm' = runTerm []

runAmixer action = run "sound" "amixer" [ "set", "Master", "-q", action ]

myScratchpads =
    [ basicNS "qutebrowser" nonFloating
    , basicNSClass "telegram-desktop" "TelegramDesktop" nonFloating
    ]
    where
    basicNS name = basicNSClass name name
    basicNSClass name classN = NS name name (className =? classN)

runNS = namedScratchpadAction myScratchpads

myKeys = flip additionalKeysP
    [ ("M-p", runProg "search" "@search@")
    , ("M-c", runNS "telegram-desktop")
    , ("M-S-m", runProg "mail" "@mail@")
    , ("M-b", runNS "qutebrowser")
    , ("M-S-l", runTerm' "journalctl" [ "-f" ])
    , ("M-q", restart "xmonad" True)
    , ("<Print>", runProg "screenshot" "@screenshot@")
    , ("<XF86AudioRaiseVolume>", runAmixer "1%+")
    , ("<XF86AudioLowerVolume>", runAmixer "1%-")
    , ("<XF86AudioMute>", runAmixer "toggle")
    ]

isUtility = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_UTILITY"

myManageHook = composeOne
    [ isDialog -?> doCenterFloat
    , isUtility -?> doFloat
    , isFullscreen -?> doFloat
    ]

myConf = def
    { modMask = if "@virtualised@" == "1" then mod1Mask else mod4Mask
    , terminal = "@terminal@"
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
