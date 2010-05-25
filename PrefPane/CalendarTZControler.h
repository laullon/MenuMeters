//
//  CalendarTZControler.h
//  MenuMeters
//
//  Created by German Laullon on 25/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CalendarTZControler : NSObject {
		
	NSArray *timeZoneNames;
	NSMutableArray *timeZones;
	
	IBOutlet NSTableView *ktzTable;
	IBOutlet NSTableView *selTable;
}

- (void)awakeFromNib;
- (IBAction)addTZ:(id)sender;


@end

