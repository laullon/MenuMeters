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
	
	NSLog(@"MenuMeterCalendar loaded.");
    return self;
}

- (NSMenu *)menu
{
	while ([theMenu numberOfItems]) {
		[theMenu removeItemAtIndex:0];
	}
	
	CalCalendarStore *calendarStore = [CalCalendarStore defaultCalendarStore];
	NSPredicate *eventsForThisYear = [CalCalendarStore eventPredicateWithStartDate:[NSDate date] 
																		   endDate:[self oneWeekLater] 
																		 calendars:[calendarStore calendars]];
	NSArray *events=[calendarStore eventsWithPredicate:eventsForThisYear];
	
	if ([events count] > 0){
        for (CalEvent *aCalendarEvent in events){
			//NSLog(@"%@ - %@",[aCalendarEvent.title capitalizedString],aCalendarEvent);
			NSMenuItem *item = (NSMenuItem *)[theMenu addItemWithTitle:@"" 
																action: nil 
														 keyEquivalent: @""];
			[item setView:[calendarVC view]];
			break;
		}
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

@end
