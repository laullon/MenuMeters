//
//  MenuMeterCalendarView.m
//  MenuMeters
//
//  Created by German Laullon on 21/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuMeterCalendarView.h"

@interface MenuMeterCalendarView (PrivateMethods)
-(NSString *)now;
@end

@implementation MenuMeterCalendarView

- initWithFrame:(NSRect)rect menuExtra:extra {
	self = [super initWithFrame:rect];
	if (!self) {
		return nil;
	}
	
	[self setFrameSize:NSMakeSize(50, [self frame].size.height)];
	menuExtra=extra;
	
	timeAttr=[[NSDictionary dictionaryWithObjectsAndKeys:
			   [NSFont systemFontOfSize:14],
			   NSFontAttributeName,
			   nil] retain];
	return self;
	
} // initWithFrame


- (void)drawRect:(NSRect)rect
{
	NSAttributedString *time = [[NSAttributedString alloc] initWithString:[self now] attributes:timeAttr];
	NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize([time size].width, [self frame].size.height - 1)] autorelease];
	if ([menuExtra isMenuDown]) {
		[menuExtra drawMenuBackground:YES];
	}
	[image lockFocus];
	[time drawAtPoint:NSMakePoint((float)0, (float)floor(2))];
	[image unlockFocus];
	[image compositeToPoint:NSMakePoint(0, 1) operation:NSCompositeSourceOver];
}

-(void)setTimeStyle:(NSDateFormatterStyle)ts{
	timeStyle=ts;
	NSAttributedString *n = [[NSAttributedString alloc] initWithString:[self now] attributes:timeAttr];
	[self setFrameSize:NSMakeSize([n size].width, [self frame].size.height)];
	[self setNeedsDisplay:YES];
}

-(NSString *)now{
	NSDateFormatter* theDateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[theDateFormatter setTimeStyle:timeStyle];	
	return [[theDateFormatter stringForObjectValue:[NSDate date]] autorelease];
}
@end
