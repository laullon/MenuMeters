//
//  CalendarTZControler.h
//  MenuMeters
//
//  Created by German Laullon on 25/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenuMetersPref.h"

@interface CalendarTZControler : NSObject {
		
	NSArray *timeZoneNames;
	NSMutableArray *timeZones;
	MenuMeterDefaults *ourPrefs;
	
	IBOutlet NSTableView *ktzTable;
	IBOutlet NSTableView *selTable;
	IBOutlet MenuMetersPref *prefs;
}

- (void)awakeFromNib;
- (IBAction)addTZ:(id)sender;
- (IBAction)rmTZ:(id)sender;
- (NSArray *)selectedTimeZones;
- (void)save;

@end

