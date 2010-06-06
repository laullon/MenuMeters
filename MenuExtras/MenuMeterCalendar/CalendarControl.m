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
int DAY_WIDTH;
int DAY_HEIGHT;
#define OFFSET_H			0
#define OFFSET_V			0


@implementation CalendarControl

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        firstDayOfWeek=[[NSCalendar currentCalendar] firstWeekday];
        
        [self setDate:[NSDate date]];
        
        dayOfWeekAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont labelFontOfSize:15],NSFontAttributeName,
							 nil];
        
	}
    
    return self;
}

- (void)awakeFromNib{
	[self setDate:[NSDate date]];
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
		[theDateFormatter setDateFormat:@"MMMM yyyy"];		
		[month setStringValue:[theDateFormatter stringFromDate:aDate]];
		
		[theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[theDateFormatter setDateStyle:NSDateFormatterLongStyle];
		NSAttributedString *title=[NSAttributedString alloc];
		NSString *now=[theDateFormatter stringForObjectValue:[NSDate date]];
		[title initWithString:now];
		[todayDate setAttributedTitle:title];
		
        [self setNeedsDisplay:YES];
    }
}

- (int)drawday:(NSDate *)aDay col:(int)col row:(int)row;
{
    NSRect tBounds=[self bounds];
    NSString * tString;
    NSSize tSize;
    NSRect tRect;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents* day = [calendar components:unitFlags fromDate:aDay];
	
    tString=[NSString stringWithFormat:@"%d",[day day]];
	
    tRect=NSMakeRect(OFFSET_H+DAY_WIDTH*col,NSHeight(tBounds)-WEEK_OFFSET_V-(row+1)*DAY_HEIGHT-OFFSET_V,DAY_WIDTH,DAY_HEIGHT);
    
	NSRect tHiliteRect;
	
	// Draw the highlight background
	
	tHiliteRect=tRect;
	//tHiliteRect.origin.x+=1.0,
	//tHiliteRect.size.width-=1.0;
	
	if (([day weekday]==7) || ([day weekday]==1)){
		[[NSColor colorWithDeviceRed:0.7686 green:0.8784 blue:0.9843 alpha:1.0] set];
        NSRectFill(tHiliteRect);
	}
	
	NSDate *today=[NSDate date];
    if ([self isSameDay:today to:aDay])
    {
		[[NSColor redColor] set];
		[NSBezierPath strokeRect:tHiliteRect];
    }
	
    
    tSize=[tString sizeWithAttributes:normalAttributes];
    
	NSDictionary *attr;
	
	if ([currentDate monthOfYear]==[day month]){
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
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray * dayArray=[dateFormatter veryShortWeekdaySymbols];
    NSString * tString;
    NSSize tSize;
    NSRect tRect;
    NSRect tBounds=[self bounds];
	
    tRect.origin=NSZeroPoint;
    DAY_WIDTH=(tBounds.size.width/7);
    DAY_HEIGHT=((tBounds.size.height-WEEK_OFFSET_V)/6);
	
	normalAttributes=[[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont labelFontOfSize:(DAY_HEIGHT-4)],NSFontAttributeName,nil] autorelease];
	otherMonthAttributes=[[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont labelFontOfSize:(DAY_HEIGHT-4)],NSFontAttributeName, [NSColor grayColor],NSForegroundColorAttributeName,nil] autorelease];

    for(int i=0;i<7;i++)
    {
        tRect=NSMakeRect(OFFSET_H+i*DAY_WIDTH,NSHeight(tBounds)-WEEK_OFFSET_V-OFFSET_V,DAY_WIDTH,WEEK_OFFSET_V);
        
        tString=[dayArray objectAtIndex:((firstDayOfWeek+i-1)%7)];
        
        tSize=[tString sizeWithAttributes:dayOfWeekAttributes];
		
        [tString drawAtPoint:NSMakePoint(NSMidX(tRect)-tSize.width*0.5+2,NSMinY(tRect)+2) 
              withAttributes:dayOfWeekAttributes];
    }
    
    // Draw the days
    NSDate *day=[self getFirstDayOfCalendar];
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	components.day = 1;
	for(int r=0;r<6;r++)
    {
		for(int c=0;c<7;c++)
		{
            [self drawday:day col:c row:r];
			day=[[NSCalendar currentCalendar] dateByAddingComponents:components toDate:day options:0];
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
	//NSLog(@"[getFirstDayOfCalendar] %@",beginningOfMonth);
	//NSLog(@"[getFirstDayOfCalendar] %@",beginningOfWeek);
	return [beginningOfWeek retain];
}

- (BOOL)isSameDay:(NSDate*)date1 to:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
	
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
	
    return [comp1 day]   == [comp2 day] &&
	[comp1 month] == [comp2 month] &&
	[comp1 year]  == [comp2 year];
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

- (IBAction) goToday: sender{
	[self setDate:[NSDate date]];
}


@end
