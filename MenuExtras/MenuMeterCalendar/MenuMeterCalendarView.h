//
//  MenuMeterCalendarView.h
//  MenuMeters
//
//  Created by German Laullon on 21/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppleUndocumented.h"
#import "MenuMetersPref.h"

@interface MenuMeterCalendarView : NSMenuExtraView {
	NSMenuExtra 	*menuExtra;
	NSDateFormatterStyle timeStyle;
	NSDateFormatterStyle dateStyle;
	NSDictionary *timeAttr;
}

-(void)setTimeStyle:(NSDateFormatterStyle)ts;

-(void)setDateStyle:(NSDateFormatterStyle)ds;

@end
