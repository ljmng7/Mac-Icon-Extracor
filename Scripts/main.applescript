use scripting additions

on run
    set theApps to choose file with prompt "Please select macOS Applications (.app):" with multiple selections allowed
    processApps(theApps)
end run

on open theDroppedItems
    processApps(theDroppedItems)
end open

on processApps(appAliases)
    set successCount to 0
    set failureMessages to ""
    set lastOutputPath to ""
    set appCount to count of appAliases

    repeat with theApp in appAliases
        set resultInfo to processApp(theApp)
        if item 1 of resultInfo is true then
            set successCount to successCount + 1
            set lastOutputPath to item 2 of resultInfo
        else
            set failureMessages to failureMessages & item 2 of resultInfo & linefeed & linefeed
        end if
    end repeat

    if lastOutputPath is not "" then
        do shell script "open -R " & quoted form of lastOutputPath
    end if

    if failureMessages is not "" then
        display dialog "Extracted " & successCount & " of " & appCount & " app(s)." & linefeed & linefeed & failureMessages buttons {"OK"} default button 1
    else if appCount > 1 then
        display dialog "Extracted " & successCount & " app icons to the Desktop." buttons {"OK"} default button 1
    end if
end processApps

on processApp(appAlias)
    set appPath to POSIX path of appAlias
    if appPath does not end with ".app/" then
        return {false, appPath & " is not a macOS .app bundle."}
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
        return {false, appName & ": " & errMsg}
    end try

    return {true, outIconPath}
end processApp
