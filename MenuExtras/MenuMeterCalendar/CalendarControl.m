/*
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain this list of conditions and the following disclaimer.
 
 The names of its contributors may not be used to endorse or promote products derived from this
 software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE CONTRIBUTORS "AS IS" AND ANY 
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT 
 SHALL THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
 OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "CalendarControl.h"

#define WEEK_OFFSET_V		18
#define DAY_WIDTH			17
#define DAY_HEIGHT			14
#define OFFSET_H			4
#define OFFSET_V			2

int numberofDayInMonthForYear(int aMonth,int aYear)
{
    if (aMonth>=0 && aMonth<12)
    {
        static int sNumberOfDay[12]={31,28,31,30,31,30,31,31,30,31,30,31};
        
        if (aMonth==1)
        {
            if (((aYear%4)==0) && ((aYear%100)!=0 || (aYear%400)==0))
            {
                return 29;
            }
        }
        
        return sNumberOfDay[aMonth];
    }
    
    return 0;
}

@implementation CalendarControl

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        firstDayOfWeek=[NSLocalizedStringFromTable(@"FirstDay",@"WBCalendar",@"No comment") intValue];
        
        [self setDate:[NSDate date]];
        
        dayOfWeekAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont labelFontOfSize:15],NSFontAttributeName,
							 nil];
        
        normalAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont labelFontOfSize:10],NSFontAttributeName,
						  nil];
        otherMonthAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont labelFontOfSize:10],NSFontAttributeName,
							  [NSColor grayColor],NSForegroundColorAttributeName,
							  nil];
	}
    
    return self;
}

- (void)dealloc
{
    [currentDate release];
    
    [super dealloc];
}

- (NSDate *) date
{
    return [[currentDate retain] autorelease];
}

- (void)setDate:(NSDate *) aDate
{
	
    if (aDate!=nil)
    {        
        if (currentDate!=nil)
        {
            [currentDate release];
        }
		currentDate=[[aDate dateWithCalendarFormat:nil timeZone:nil] retain];
        firstday=1;
		
		NSDateFormatter* theDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[theDateFormatter setDateFormat:@"MMMM"];
		[month setStringValue:[theDateFormatter stringFromDate:aDate]];

        [self setNeedsDisplay:YES];
    }
}

- (int)drawday:(NSDate *)aDay col:(int)col row:(int)row;
{
    NSRect tBounds=[self bounds];
    NSString * tString;
    NSSize tSize;
    NSRect tRect;
	NSCalendarDate *day=[[aDay dateWithCalendarFormat:nil timeZone:nil] retain];
	
    tString=[NSString stringWithFormat:@"%d",[day dayOfMonth]];
	
    tRect=NSMakeRect(OFFSET_H+DAY_WIDTH*col,NSHeight(tBounds)-WEEK_OFFSET_V-(row+1)*DAY_HEIGHT-OFFSET_V,DAY_WIDTH,DAY_HEIGHT);
    
	//XXX arreglar esto
	NSDate *today=[NSDate date];
	NSLog(@" %@ == %@ > %@",today,day,[today isEqualToDate:day]);
    if ([today isEqualToDate:day])
    {
        NSRect tHiliteRect;
        
        // Draw the highlight background
        
        tHiliteRect=tRect;
        tHiliteRect.origin.x+=1.0,
        tHiliteRect.size.height-=1.0;
        
        [[NSColor colorWithDeviceRed:0.7686
                               green:0.8784
                                blue:0.9843
							   alpha:1.0] set];
        
        NSRectFill(tHiliteRect);
    }
    
    tSize=[tString sizeWithAttributes:normalAttributes];
    
	NSDictionary *attr;
	
	if ([currentDate monthOfYear]==[day monthOfYear]){
		attr=normalAttributes;
	}else {
		attr=otherMonthAttributes;
	}
	
    [tString drawAtPoint:NSMakePoint(NSMidX(tRect)-tSize.width*0.5+1,NSMinY(tRect)) 
          withAttributes:attr];
    
    return 0;
}

- (void)drawRect:(NSRect) aRect
{
    int i=0;
    NSString * dayArray[7]={@"S", @"M", @"T", @"W", @"T", @"F", @"S"};
    NSString * tString;
    NSSize tSize;
    NSRect tRect;
    NSRect tBounds=[self bounds];
    
    // Draw the background
    
    tRect.origin=NSZeroPoint;
    
    // Draw the week header
    
    for(i=0;i<7;i++)
    {
        tRect=NSMakeRect(OFFSET_H+i*DAY_WIDTH,NSHeight(tBounds)-WEEK_OFFSET_V-OFFSET_V,DAY_WIDTH,WEEK_OFFSET_V);
        
        tString=dayArray[(firstDayOfWeek+i)%7];
        
        tSize=[tString sizeWithAttributes:dayOfWeekAttributes];
		
        [tString drawAtPoint:NSMakePoint(NSMidX(tRect)-tSize.width*0.5+2,NSMinY(tRect)+2) 
              withAttributes:dayOfWeekAttributes];
    }
    
    // Draw the days
	NSTimeInterval oneDay=(24*60*60);
    NSDate *day=[self getFirstDayOfCalendar];
	for(int r=0;r<7;r++)
    {
		for(int c=0;c<7;c++)
		{
            [self drawday:day col:c row:r];
			day=[day addTimeInterval:oneDay];
		}
    }
}

- (void)setAction:(SEL) aAction
{
    action=aAction;
}

- (void)setTarget:(id) aTarget
{
    target=aTarget;
}

- (NSDate *)getFirstDayOfCalendar{
	NSDate *day = [self date];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *beginningOfMonth = nil;
	NSDate *beginningOfWeek = nil;
	[gregorian rangeOfUnit:kCFCalendarUnitMonth startDate:&beginningOfMonth interval:NULL forDate: day];
	[gregorian rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek interval:NULL forDate: beginningOfMonth];
	NSLog(@"[getFirstDayOfCalendar] %@",beginningOfMonth);
	NSLog(@"[getFirstDayOfCalendar] %@",beginningOfWeek);
	return [beginningOfWeek retain];
}

- (IBAction) prevMonth: sender{
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	components.month = -1;
	NSDate *oneMonthFromNow = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[self date] options:0];
	[self setDate:oneMonthFromNow];
}

- (IBAction) nextMonth: sender{
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	components.month = 1;
	NSDate *oneMonthFromNow = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[self date] options:0];
	[self setDate:oneMonthFromNow];
}

@end
