//
//  CalendarTZControler.m
//  MenuMeters
//
//  Created by German Laullon on 25/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalendarPrefControler.h"
#import "MenuMeterDefaults.h"

@implementation CalendarPrefControler

- (void)awakeFromNib{
	NSLog(@"[CalendarTZControler] awakeFromNib");
	[ktzTable setDataSource:self];
	[selTable setDataSource:self];
	timeZoneNames = [NSTimeZone knownTimeZoneNames];
	timeZones=[NSMutableArray arrayWithCapacity:10];
	
	NSMenu *menuTime = [[[NSMenu alloc] init] autorelease];
	NSMenu *menuDate = [[[NSMenu alloc] init] autorelease];
	
	NSDateFormatter* theDateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	
	[theDateFormatter setTimeStyle:NSDateFormatterShortStyle];	
	NSString *timeString=[theDateFormatter stringForObjectValue:[NSDate date]];
	NSMenuItem *menuItem = [menuTime addItemWithTitle:timeString action:nil keyEquivalent:@""];
	[menuItem setTag:NSDateFormatterShortStyle];
	
	[theDateFormatter setTimeStyle:NSDateFormatterMediumStyle];	
	timeString=[theDateFormatter stringForObjectValue:[NSDate date]];
	menuItem = [menuTime addItemWithTitle:timeString action:nil keyEquivalent:@""];
	[menuItem setTag:NSDateFormatterMediumStyle];
	
	[theDateFormatter setTimeStyle:NSDateFormatterLongStyle];	
	timeString=[theDateFormatter stringForObjectValue:[NSDate date]];
	menuItem = [menuTime addItemWithTitle:timeString action:nil keyEquivalent:@""];
	[menuItem setTag:NSDateFormatterLongStyle];
	
	[theDateFormatter setTimeStyle:NSDateFormatterFullStyle];	
	timeString=[theDateFormatter stringForObjectValue:[NSDate date]];
	menuItem = [menuTime addItemWithTitle:timeString action:nil keyEquivalent:@""];
	[menuItem setTag:NSDateFormatterFullStyle];
	
	[timePopUp setMenu:menuTime];
	
	theDateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	
	[theDateFormatter setDateStyle:NSDateFormatterShortStyle];	
	timeString=[theDateFormatter stringForObjectValue:[NSDate date]];
	menuItem = [menuDate addItemWithTitle:timeString action:nil keyEquivalent:@""];
	[menuItem setTag:NSDateFormatterShortStyle];
	
	[theDateFormatter setDateStyle:NSDateFormatterMediumStyle];	
	timeString=[theDateFormatter stringForObjectValue:[NSDate date]];
	menuItem = [menuDate addItemWithTitle:timeString action:nil keyEquivalent:@""];
	[menuItem setTag:NSDateFormatterMediumStyle];
	
	[theDateFormatter setDateStyle:NSDateFormatterLongStyle];	
	timeString=[theDateFormatter stringForObjectValue:[NSDate date]];
	menuItem = [menuDate addItemWithTitle:timeString action:nil keyEquivalent:@""];
	[menuItem setTag:NSDateFormatterLongStyle];
	
	[theDateFormatter setDateStyle:NSDateFormatterFullStyle];	
	timeString=[theDateFormatter stringForObjectValue:[NSDate date]];
	menuItem = [menuDate addItemWithTitle:timeString action:nil keyEquivalent:@""];
	[menuItem setTag:NSDateFormatterFullStyle];
	
	[datePopUp setMenu:menuDate];
	
	ourPrefs = [[MenuMeterDefaults alloc] init];
	[timeZones addObjectsFromArray:[ourPrefs load:@"calendarSelectedTimeZones"
										  default:nil]];
	[timePopUp selectItemWithTag:[[ourPrefs load:@"calendarTimeFormat"
										 default:[NSNumber numberWithInteger:NSDateFormatterShortStyle]] integerValue]];
	[datePopUp selectItemWithTag:[[ourPrefs load:@"calendarDateFormat"
										 default:[NSNumber numberWithInteger:NSDateFormatterFullStyle]] integerValue]];

}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	int res=0;
	if(tableView==ktzTable){
		res=[timeZoneNames count];
	}else{
		res=[timeZones count];
	}
	return res;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	id res=nil;
	if(tableView==ktzTable){
		res=[timeZoneNames objectAtIndex:row];
	}else{
		res=[timeZones objectAtIndex:row];
	}
	return res;
}

- (NSArray *)selectedTimeZones{
	return timeZones;
}

- (IBAction)rmTZ:(id)sender{
	[timeZones removeObjectAtIndex:[selTable selectedRow]];
	[selTable reloadData];
	[self save:self];
}

- (IBAction)addTZ:(id)sender{
	id tz=[timeZoneNames objectAtIndex:[ktzTable selectedRow]];
	
	for (NSString *stz in timeZones){
		if([stz isEqualToString:tz]){
			return;
		}
	}
	
	[timeZones addObject:tz];
	NSLog(@"addTZ: %@ (%d)",tz,[timeZones count]);
	
	[selTable reloadData];
	[self save:self];
}

- (IBAction)save:(id)sender{
	[ourPrefs save:@"calendarSelectedTimeZones" value:timeZones];
	[ourPrefs save:@"calendarTimeFormat" value:[NSNumber numberWithInteger:[timePopUp selectedTag]]];
	[ourPrefs save:@"calendarDateFormat" value:[NSNumber numberWithInteger:[datePopUp selectedTag]]];
	[ourPrefs syncWithDisk];
	if ([prefs isExtraWithBundleIDLoaded:kCalMenuBundleID]) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kCalMenuBundleID
																	   object:kPrefChangeNotification];
	}
	
}

@end
