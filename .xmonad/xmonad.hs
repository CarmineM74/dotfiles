--import DBus.Client.Simple
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops (ewmh)
import qualified XMonad.StackSet as W
import XMonad.Prompt
import XMonad.Prompt.Input(inputPromptWithCompl,(?+))
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh
import XMonad.Util.Run
import XMonad.Util.Scratchpad
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import System.Taffybar.Hooks.PagerHints (pagerHints)

import Data.List

myTerminal           = "urxvt -e tmux"
myFont               = "xft:DejaVu Sans:size=10"

focusColor           = "#60ff45"
textColor            = "#c0c0a0"
lightTextColor       = "#fffff0"
backgroundColor      = "#304520"
lightBackgroundColor = "#456030"
urgentColor          = "#ffc000"

myWorkspaces         = ["1:main","2:chat","3:web","4:ssh","5:remmina","6:office","7:altro"]

myLayout = tiled ||| Mirror tiled ||| Full
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 2/3
    delta   = 5/100

myManageHook = composeAll [ 
                            className =? "Remmina"                          --> moveToRemmina,
                            fmap ("weechat" `isInfixOf`) title              --> moveToChat,
                            className =? "Firefox"                          --> moveToWeb,
                            title =? "LibreOffice"                          --> moveToOffice,
                            fmap ("libreoffice-calc" `isInfixOf`) className --> moveToOffice
                          ]
                where
                  moveToRemmina = doF $ W.shift "5:remmina"
                  moveToChat    = doF $ W.shift "2:chat"
                  moveToWeb     = doF $ W.shift "3:web"
                  moveToOffice  = doF $ W.shift "6:office"

myXPConfig :: XPConfig
myXPConfig = defaultXPConfig { 
  font          = myFont
  , bgColor     = backgroundColor
  , fgColor     = textColor
  , fgHLight    = lightTextColor
  , bgHLight    = lightBackgroundColor
  , borderColor = lightBackgroundColor
}

main = do
  xmonad $ ewmh $ pagerHints $ defaultConfig {
      terminal = myTerminal,
      borderWidth = 2,
      workspaces = myWorkspaces,
      manageHook = scratchpadManageHookDefault <+> manageDocks <+> myManageHook <+> manageHook defaultConfig,
      layoutHook = avoidStruts $ layoutHook defaultConfig
      } `additionalKeys` [
        ((mod1Mask .|. shiftMask, xK_x), shellPrompt myXPConfig),
        ((mod1Mask .|. shiftMask, xK_s), sshPrompt myXPConfig),
        ((mod1Mask .|. shiftMask, xK_u), scratchpadSpawnActionTerminal "urxvt"),
        ((mod1Mask .|. shiftMask, xK_w), spawn "urxvt -name weechat -e weechat"),
        ((mod1Mask .|. shiftMask, xK_f), spawn "firefox"),
        ((mod1Mask .|. shiftMask, xK_c), spawn "libreoffice --calc"),
        ((mod1Mask .|. shiftMask, xK_o), spawn "libreoffice"),
        ((mod1Mask .|. shiftMask, xK_r), spawn "remmina")
      ] 

