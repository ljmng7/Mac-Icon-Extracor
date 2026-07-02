use scripting additions

on run
    set theApp to choose file with prompt "Please select a macOS Application (.app):"
    processApp(theApp)
end run

on open theDroppedItems
    repeat with theApp in theDroppedItems
        processApp(theApp)
    end repeat
end open

on processApp(appAlias)
    set appPath to POSIX path of appAlias
    if appPath does not end with ".app/" then
        display dialog "Please select a macOS .app bundle." buttons {"OK"} default button 1
        return
    end if
    set appName to do shell script "basename " & quoted form of appPath
    set iconName to do shell script "echo " & quoted form of appName & " | sed 's/.app$//'"
    
    set bundlePath to POSIX path of (path to me)
    set decantScript to bundlePath & "Contents/Resources/bin/decant/decant"
    
    set outDir to POSIX path of (path to desktop folder)
    set outIconPath to outDir & iconName & "_Extracted.icon"
    
    try
        do shell script "export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH; zsh " & quoted form of decantScript & " " & quoted form of appPath & " " & quoted form of outIconPath
    on error errMsg number errNo
        display dialog "Error extracting icon: " & errMsg buttons {"OK"} default button 1
        return
    end try
    
    do shell script "open -R " & quoted form of outIconPath
end processApp
