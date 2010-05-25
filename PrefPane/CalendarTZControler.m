//
//  CalendarTZControler.m
//  MenuMeters
//
//  Created by German Laullon on 25/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalendarTZControler.h"
#import "MenuMeterDefaults.h"

@implementation CalendarTZControler

- (void)awakeFromNib{
	NSLog(@"[CalendarTZControler] awakeFromNib");
	[ktzTable setDataSource:self];
	[selTable setDataSource:self];
	timeZoneNames = [NSTimeZone knownTimeZoneNames];
	timeZones=[NSMutableArray arrayWithCapacity:10];
	
	ourPrefs = [[MenuMeterDefaults alloc] init];
	[timeZones addObjectsFromArray:[ourPrefs loadArray:@"calendarSelectedTimeZones"]];
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
	[self save];
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
	[self save];
}

- (void)save{
	[ourPrefs save:@"calendarSelectedTimeZones" array:timeZones];
	[ourPrefs syncWithDisk];
}

@end
