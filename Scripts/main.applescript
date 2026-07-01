on run
    set theApp to choose file with prompt "Please select a macOS Application (.app):" of type {"com.apple.application-bundle", "app"}
    processApp(theApp)
end run

on open theDroppedItems
    repeat with theApp in theDroppedItems
        processApp(theApp)
    end repeat
end open

on processApp(appAlias)
    set appPath to POSIX path of appAlias
    set appName to do shell script "basename " & quoted form of appPath
    set iconName to do shell script "echo " & quoted form of appName & " | sed 's/.app$//'"
    
    set bundlePath to POSIX path of (path to me)
    set decantScript to bundlePath & "Contents/Resources/bin/decant/decant"
    set cropScript to bundlePath & "Contents/Resources/Scripts/crop_and_merge.py"
    
    set outDir to POSIX path of (path to desktop folder)
    set outIconPath to outDir & iconName & "_Extracted.icon"
    
    try
        do shell script "export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH; zsh " & quoted form of decantScript & " " & quoted form of appPath & " \"\" " & quoted form of outIconPath & " >/dev/null 2>&1"
    on error errMsg
    end try
    
    try
        do shell script "export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH; python3 " & quoted form of cropScript & " " & quoted form of outIconPath
    on error errMsg
        display dialog "Error cropping SVGs: " & errMsg buttons {"OK"} default button 1
        return
    end try
    
    do shell script "open -R " & quoted form of outIconPath
end processApp
