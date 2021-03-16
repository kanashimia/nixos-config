{-# LANGUAGE OverloadedStrings #-}

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
import System.CPU
import Data.Maybe

main = launch . ewmh . myKeys =<< myModKeyHook myConf

myKeys = flip additionalKeysP
    [ ("M-p", spawn "@search@")
    , ("M-]", spawn "@chat@")
    , ("M-<Backspace>", spawn "@browser@")
    , ("M-q", restart "xmonad" True)
    , ("<Print>", spawn "@screenshot@")
    , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 1%+")
    , ("<XF86AudioLowerVolume>", spawn "amixer set Master 1%-")
    , ("<XF86AudioMute>", spawn "amixer set Master toggle")
    ]

isUtility = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_UTILITY"

myFloatHook = composeOne
    [ isDialog -?> doCenterFloat
    , isUtility -?> doFloat
    , className =? "QjackCtl" -?> doFloat
    ]

myModKeyHook conf = do
    cpuFlags <- map flags <$> getCPUs
    let hypervised = or $ elem "hypervisor" <$> catMaybes cpuFlags
    pure $ conf { modMask = mod4Mask }

myConf = def
    { borderWidth = 1
    , normalBorderColor = "#676e95"
    , focusedBorderColor = "#d5d5e1"
    , terminal = "@terminal@"
    , manageHook = myFloatHook
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
