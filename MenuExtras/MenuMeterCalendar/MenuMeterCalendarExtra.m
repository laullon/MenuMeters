//
//  MenuMeterCalendarExtra.m
//  MenuMeters
//
//  Created by German Laullon on 20/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuMeterCalendarExtra.h"
#import <CalendarStore/CalendarStore.h>

@implementation MenuMeterCalendarExtra

- initWithBundle:(NSBundle *)bundle {
	self = [super initWithBundle:bundle];
	if (!self) {
		return nil;
	}
	
	NSLog(@"MenuMeterCalendarExtra bundel = %@",bundle);
	calendarVC = [[NSViewController alloc] initWithNibName:@"Calendar" bundle:bundle];
	
    theView = [[MenuMeterCalendarView alloc] initWithFrame:
			   [[self view] frame] menuExtra:self];
    [self setView:theView];
	
    // prepare "dummy" menu, without any actions
    theMenu = [[NSMenu alloc] initWithTitle: @""];
    [theMenu setAutoenablesItems: NO];
    [theMenu addItemWithTitle: @"1" action: nil keyEquivalent: @""];
    [theMenu addItemWithTitle: @"2" action: nil keyEquivalent: @""];
    [theMenu addItemWithTitle: @"3" action: nil keyEquivalent: @""];
	
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:1
												   target:self
												 selector:@selector(updateDisplay:)
												 userInfo:nil
												  repeats:YES];
	
	NSString *prefBundlePath = [[[bundle bundlePath] stringByDeletingLastPathComponent]
								stringByAppendingPathComponent:kPrefBundleName];
	ourPrefs = [[[[NSBundle bundleWithPath:prefBundlePath] principalClass] alloc] init];
	if (!ourPrefs) {
		NSLog(@"MenuMeterCalendarExtra unable to connect to preferences. Abort.");
		[self release];
		return nil;
	}
	
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self 
														selector:@selector(configFromPrefs:) 
															name:kCalMenuBundleID 
														  object:kPrefChangeNotification];
	
	[self configFromPrefs:nil];
	
	NSLog(@"MenuMeterCalendar loaded.");
    return self;
}

- (NSMenu *)menu
{
	while ([theMenu numberOfItems]) {
		[theMenu removeItemAtIndex:0];
	}
	NSMenuItem *item = (NSMenuItem *)[theMenu addItemWithTitle:@"" 
														action: nil 
												 keyEquivalent: @""];
	
	[item setView:[calendarVC view]];	
	
	for(NSString *tzName in timeZones){
		NSTimeZone *tz=[NSTimeZone timeZoneWithName:tzName];
		NSDateFormatter* theDateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
		[theDateFormatter setTimeZone:tz];	
		[theDateFormatter setTimeStyle:NSDateFormatterLongStyle];	
		
		NSString *t=[NSString stringWithFormat:@"%@: %@", [tz name], [theDateFormatter stringForObjectValue:[NSDate date]]];
		[theMenu addItemWithTitle:t
						   action: nil 
					keyEquivalent: @""];	
	}	
	
	return theMenu;
}

- (void)dealloc
{
    [theMenu release];
    [theView release];
    [super dealloc];
}

-(NSDate*)oneWeekLater        
{
	NSTimeInterval oneWeek = 24 * 60 * 60 * 7;
	NSDate *today = [[NSDate alloc] init];
    
	NSDate *res=[today addTimeInterval:oneWeek];
	NSLog(@"endOfWeek = %@",res);
    return res;
}

- (void)updateDisplay:(NSTimer *)timer {
	[theView setNeedsDisplay:YES];
}

- (void)configFromPrefs:(NSNotification *)notification{
	[ourPrefs syncWithDisk];	
	timeZones=[ourPrefs load:@"calendarSelectedTimeZones" default:nil];
	NSNumber *ts=[ourPrefs load:@"calendarTimeFormat" default:[NSNumber numberWithInteger:NSDateFormatterShortStyle]];
	NSNumber *ds=[ourPrefs load:@"calendarDateFormat" default:[NSNumber numberWithInteger:NSDateFormatterShortStyle]];
	
	[theView setTimeStyle:[ts integerValue]];
	[theView setDateStyle:[ds integerValue]];
	[theView setNeedsDisplay:YES];	
}

@end
