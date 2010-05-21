//
//  MenuMeterCalendarExtra.m
//  MenuMeters
//
//  Created by German Laullon on 20/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuMeterCalendarExtra.h"


@implementation MenuMeterCalendarExtra

- initWithBundle:(NSBundle *)bundle {
	self = [super initWithBundle:bundle];
	if (!self) {
		return nil;
	}
	
	//extraView = [[MenuMeterNetView alloc] initWithFrame:[[self view] frame] menuExtra:self];
	[self setTitle:@"Hello"];
	
	NSLog(@"MenuMeterCalendar loaded.");
    return self;
}

/**
- (NSImage *)image {
	NSImage *currentImage = [[[NSImage alloc] initWithSize:NSMakeSize((float)menuWidth,
																	  [extraView frame].size.height - 1)] autorelease];
	
	NSAttributedString *renderRxString = [[[NSAttributedString alloc]
										   initWithString:@"hola"
										   attributes:[NSDictionary dictionaryWithObjectsAndKeys:
													   [NSFont systemFontOfSize:9.5f],
													   NSFontAttributeName,
													   nil]] autorelease];	
	[renderRxString drawAtPoint:NSMakePoint((float)ceil(menuWidth - [renderRxString size].width), (float)floor([image size].height / 2) - 1)];
}
 **/

@end
