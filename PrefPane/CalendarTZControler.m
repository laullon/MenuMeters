//
//  CalendarTZControler.m
//  MenuMeters
//
//  Created by German Laullon on 25/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalendarTZControler.h"


@implementation CalendarTZControler

- (void)awakeFromNib{
	NSLog(@"[CalendarTZControler] awakeFromNib");
	[ktzTable setDataSource:self];
	timeZoneNames = [NSTimeZone knownTimeZoneNames];
	timeZones=[NSMutableArray arrayWithCapacity:10];
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

- (IBAction)addTZ:(id)sender{
	id tz=[timeZoneNames objectAtIndex:[ktzTable selectedRow]];
	[timeZones addObject:tz];
	NSLog(@"addTZ: %@ (%d)",tz,[timeZones count]);
	[selTable setNeedsDisplay:YES];
}

@end
