//
//  MenuMeterCalendarExtra.h
//  MenuMeters
//
//  Created by German Laullon on 20/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "AppleUndocumented.h"
#import "MenuMeters.h"
#import "MenuMeterDefaults.h"
#import "MenuMeterCalendarView.h"

@interface MenuMeterCalendarExtra : NSMenuExtra {
	NSMenu *theMenu;
	NSViewController *calendarVC;
	NSTimer *updateTimer;
	NSDateFormatterStyle timeStyle;
	NSArray *timeZones;

	MenuMeterCalendarView *theView;
	MenuMeterDefaults *ourPrefs;
}

-(NSDate*)oneWeekLater;
- (void)updateDisplay:(NSTimer *)timer;
- (void)configFromPrefs:(NSNotification *)notification;

@end
