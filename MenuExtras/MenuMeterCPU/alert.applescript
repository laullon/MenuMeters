tell application "GrowlHelperApp"
	set the allNotificationsList to {"Test Notification", "Another Test Notification"}
	set the enabledNotificationsList to {"Test Notification"}
	register as application "Growl AppleScript Sample" all notifications allNotificationsList default notifications enabledNotificationsList icon of application "Script Editor"
	notify with name "Test Notification" title "Test Notification" description "This is a test AppleScript notification." application name "Growl AppleScript Sample"
	notify with name "Another Test Notification" title "Another Test Notification :) " description "Alas you won't see me until you enable me yourself..." application name "Growl AppleScript Sample"
end tell
