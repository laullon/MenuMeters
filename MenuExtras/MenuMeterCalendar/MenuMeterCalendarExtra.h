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
	MenuMeterCalendarView *theView;
	NSViewController *calendarVC;
	NSTimer *updateTimer;
}

-(NSDate*)oneWeekLater;
- (void)updateDisplay:(NSTimer *)timer;

@end
