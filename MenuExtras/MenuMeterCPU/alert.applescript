tell application "GrowlHelperApp"
	set the allNotificationsList to {"CPU"}
	register as application "MenuMeters" all notifications allNotificationsList default notifications allNotificationsList
	notify with name "%TYPE%" title "MenuMeters" description "%DESCRIPTION%" application name "MenuMeters"
end tell
