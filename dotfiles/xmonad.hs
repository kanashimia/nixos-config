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

-- main = xmonad $ docks $ ewmh $ additionalKeys myConf myKeys
main = xmonad
  -- =<< myXmobar (docks
  $ ewmh $ additionalKeys myConf myKeys

-- myXmobar = statusBar "xmobar" myPP $ \conf -> (modMask conf, xK_b)

myKeys =
    [ ((myM, xK_p), spawn "rofi -show drun -show-icons -m -4")
    --, ((myM, xK_s), scratchpadSpawnActionCustom "alacritty --class scratchpad")
    , ((myM, xK_s), scratchpadSpawnActionCustom "st -n scratchpad")
    --, ((myM, xK_s), scratchpadSpawnAction myConf)
    , ((myM, xK_Tab), sendMessage NextLayout)
    , ((myM, xK_space), sendMessage ToggleLayout)
    , ((myM, xK_BackSpace), spawn "vivaldi")
    , ((myM, xK_bracketright), spawn "discord")
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
    ]
    -- ++ [ ((myM, key), warpToScreen sc 0.5 0.5) | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..] ]
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
    -- , startupHook = spawn "~/.config/polybar/launch.sh"
    }

myLayoutHook = avoidStruts
    $ toggleLayouts Full
    $ ResizableTall master delta frac []
    ||| ThreeColMid master delta frac
    where
    master = 1
    delta = 3/100
    frac = 5/10

myScratchHook = scratchpadManageHook
    $ RationalRect ((1-size)/2) 0 (size-0.003) (size-0.007)
    where
    size = 7/10

-- {-# OPTIONS_GHC -Wno-missing-signatures #-}
-- {-# LANGUAGE TupleSections, LambdaCase #-}
-- {-# LANGUAGE FlexibleContexts #-}
-- {-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}

-- import Data.Foldable
-- import Data.Char (isDigit)

-- import XMonad.Layout.Grid
-- import XMonad.Layout.AutoMaster
-- import XMonad.Layout.CenteredMaster
-- import XMonad.Layout.Roledex
-- import XMonad.Hooks.XPropManage

-- import Data.Maybe (maybeToList)
-- import Control.Monad ((>=>), join, liftM, when)

-- import XMonad.Util.Run
-- import XMonad.Util.WorkspaceCompare
-- import XMonad.Layout.LayoutModifier

-- import qualified XMonad.StackSet as S
-- import qualified Data.Map as M
-- import Codec.Binary.UTF8.String (encodeString)
-- import Data.List (intersperse, stripPrefix, isPrefixOf, sortBy)
-- import Data.Maybe ( isJust, catMaybes, mapMaybe, fromMaybe )

-- import XMonad.Layout.Decoration
-- import XMonad.Util.Types

-- myStrutsKey = (,xK_b) . modMask

myPP = xmobarPP
    { ppCurrent = xmobarColor "#a6accd" "" . wrap "[" "]" . xmobarColor "#d5d5e1" ""
    , ppHidden = myClickable <*> myHidden . myFilter
    , ppHiddenNoWindows = myClickable <*> const "   "
    , ppVisible = myClickable <*> xmobarColor "#676e95" "" . wrap "[" "]" . xmobarColor "#a6accd" ""
    , ppOrder = pure . head
    }
  where
    myFilter "NSP" = ""
    myFilter x = x
    myClickable n = xmobarAction ("xdotool key Super+" ++ n) "1"
    myHidden = xmobarColor "#444267" ""
        . wrap "|" "|"
        . xmobarColor "#676e95" ""

-- statusBar' conf = do
--     h <- spawnPipe "xmobar"
--     return $ docks $ conf
--         { layoutHook = avoidStruts (layoutHook conf)
--         , logHook = do
--             logHook conf
--             dynamicLogWithPP' myPP { ppOutput = hPutStrLn h }
--         , keys  =  M.union <$> keys' <*> (keys conf)
--         }
--     where
--     keys' = (`M.singleton` sendMessage ToggleStruts) . myStrutsKey

-- dynamicLogWithPP' pp = dynamicLogString' pp >>= io . ppOutput pp

-- dynamicLogString' pp = do
--     winset <- gets windowset
--     sort' <- ppSort pp
--     let ws = pprWindowSet' sort' pp winset
--     return $ encodeString . sepBy (ppSep pp) $ [ws]

-- pprWindowSet' sort' pp s = sepBy (ppWsSep pp) . map fmt . sort' . scratchpadFilterOutWorkspace  $
--             map S.workspace (S.current s : S.visible s) ++ S.hidden s
--     where
--     this = S.currentTag s
--     fmt w = printer pp (S.tag w)
--            where printer
--                     | S.tag w == this && isJust (S.stack w) = const $ wrap "[" "]" . xmobarColor "#89ddff" ""
--                     | S.tag w == this    = ppCurrent
--                     | isJust (S.stack w) = ppHidden
--                     | otherwise          = ppHiddenNoWindows
--         -- any (\x -> maybe False (== S.tag w) (S.findTag x s)) urgents  = ppUrgent

-- sepBy sep = concat . intersperse sep . filter (not . null)

-- addNETSupported :: Atom -> X ()
-- addNETSupported x = withDisplay $ \dpy -> do
--     r <- asks theRoot
--     a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
--     a <- getAtom "ATOM"
--     liftIO $ do
--        sup <- join . maybeToList <$> getWindowProperty32 dpy a_NET_SUPPORTED r
--        when (fromIntegral x `notElem` sup) $
--          changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

-- addEWMHFullscreen :: X ()
-- addEWMHFullscreen = do
--     wms <- getAtom "_NET_WM_STATE"
--     wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
--     mapM_ addNETSupported [wms, wfs]
