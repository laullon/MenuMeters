//
//  MenuMeterCalendarView.m
//  MenuMeters
//
//  Created by German Laullon on 21/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuMeterCalendarView.h"


@implementation MenuMeterCalendarView

- initWithFrame:(NSRect)rect menuExtra:extra {
	self = [super initWithFrame:rect];
	if (!self) {
		return nil;
	}
	
	[self setFrameSize:NSMakeSize(45, [self frame].size.height)];
	[self setNeedsDisplay:YES];
	menuExtra=extra;
	
    return self;
	
} // initWithFrame


- (void)drawRect:(NSRect)rect
{
	NSDateFormatter* theDateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[theDateFormatter setTimeStyle:NSDateFormatterShortStyle];	
	NSString *timeString=[theDateFormatter stringForObjectValue:[NSDate date]];
	
/*	theDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[theDateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString *dateString=[theDateFormatter stringForObjectValue:[NSDate date]]; */
	
	
	
	NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize((float)45,
															   [self frame].size.height - 1)] autorelease];
	
/*	NSAttributedString *date = [[[NSAttributedString alloc]
								 initWithString:dateString
								 attributes:[NSDictionary dictionaryWithObjectsAndKeys:
											 [NSFont systemFontOfSize:9.5f],
											 NSFontAttributeName,
											 nil]] autorelease]; */
	
	NSAttributedString *time = [[[NSAttributedString alloc]
								 initWithString:timeString
								 attributes:[NSDictionary dictionaryWithObjectsAndKeys:
											 [NSFont systemFontOfSize:14],
											 NSFontAttributeName,
											 nil]] autorelease];
	if ([menuExtra isMenuDown]) {
		[menuExtra drawMenuBackground:YES];
	}
	[image lockFocus];
	//[date drawAtPoint:NSMakePoint((float)0, (float)floor([image size].height / 2) - 1)];
	[time drawAtPoint:NSMakePoint((float)0, (float)floor(2))];
	[image unlockFocus];
	[image compositeToPoint:NSMakePoint(0, 1) operation:NSCompositeSourceOver];
}

@end
