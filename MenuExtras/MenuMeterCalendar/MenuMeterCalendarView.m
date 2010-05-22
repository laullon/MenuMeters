//
//  MenuMeterCalendarView.m
//  MenuMeters
//
//  Created by German Laullon on 21/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuMeterCalendarView.h"


@implementation MenuMeterCalendarView

- (void)drawRect:(NSRect)rect
{
    [[NSColor purpleColor] set];
    NSRect smallerRect = NSInsetRect( rect, 4.0, 4.0 );
    [[NSBezierPath bezierPathWithOvalInRect: smallerRect] fill];
}

@end
