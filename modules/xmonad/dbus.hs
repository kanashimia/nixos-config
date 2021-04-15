{-# LANGUAGE OverloadedStrings, TypeApplications #-}

import DBus
import DBus.Client
import Data.Word
import System.Process
import System.FilePath

messageDestination = Just "org.freedesktop.systemd1"
messageBody pid name =
    [ toVariant @String
        unitName
    , toVariant @String
        "fail"
    , toVariant @[(String, Variant)]
        [("PIDs", toVariant @[Word32] [pid])]
    , toVariant @[(String, [(String, Variant)])]
        []
    ]
    where
    unitName = takeBaseName name ++ "-" ++ show pid ++ ".scope"

object = "/org/freedesktop/systemd1"
interface = "org.freedesktop.systemd1.Manager"
member = "StartTransientUnit"

request pid name = (methodCall object interface member)
    { methodCallDestination = messageDestination
    , methodCallBody = messageBody pid name
    }

main = do
    command <- getLine
    client <- connectSession
    Just pid <- getPid =<< spawnCommand ("systemd-cat -t cat " ++ command)
    reply <- call_ client $ request (fromIntegral pid) command
    print reply
