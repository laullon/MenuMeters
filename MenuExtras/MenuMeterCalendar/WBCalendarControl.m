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

#import "WBCalendarControl.h"

#define WBCALENDARCONTROL_WEEK_OFFSET_V		18
#define WBCALENDARCONTROL_DAY_WIDTH			17
#define WBCALENDARCONTROL_DAY_HEIGHT		14
#define WBCALENDARCONTROL_OFFSET_H			4
#define WBCALENDARCONTROL_OFFSET_V			2

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

@implementation WBCalendarControl

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
        int i;
        int numberOfDays;
        
        if (currentDate!=nil)
        {
            [currentDate release];
        }
        
        currentDate=[[aDate dateWithCalendarFormat:nil timeZone:nil] retain];
        
        numberOfDays=numberofDayInMonthForYear([currentDate monthOfYear]-1,[currentDate yearOfCommonEra]);
        
        firstday=((([currentDate dayOfWeek]-([currentDate dayOfMonth]%7)+1-firstDayOfWeek))+7)%7;
        
        for(i=0;i<firstday;i++)
        {
            monthday[i]=0;
        }
        
        for(i=firstday;i<(firstday+numberOfDays);i++)
        {
            monthday[i]=i-firstday+1;
        }
        
        for(i=(firstday+numberOfDays);i<42;i++)
        {
            monthday[i]=0;
        }
        
        [self setNeedsDisplay:YES];
    }
}

- (int)drawday:(int) aDay
{
    NSRect tBounds=[self bounds];
    int tRow,tColumn;
    NSString * tString;
    NSSize tSize;
    NSRect tRect;
    
    tRow=aDay/7;
    tColumn=aDay-(tRow*7);
    
    tString=[NSString stringWithFormat:@"%d",monthday[aDay]];
	
    tRect=NSMakeRect(WBCALENDARCONTROL_OFFSET_H+WBCALENDARCONTROL_DAY_WIDTH*tColumn,NSHeight(tBounds)-WBCALENDARCONTROL_WEEK_OFFSET_V-(tRow+1)*WBCALENDARCONTROL_DAY_HEIGHT-WBCALENDARCONTROL_OFFSET_V,WBCALENDARCONTROL_DAY_WIDTH,WBCALENDARCONTROL_DAY_HEIGHT);
    
    if ([currentDate dayOfMonth]==monthday[aDay])
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
    
    [tString drawAtPoint:NSMakePoint(NSMidX(tRect)-tSize.width*0.5+1,NSMinY(tRect)) 
          withAttributes:normalAttributes];
    
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
        tRect=NSMakeRect(WBCALENDARCONTROL_OFFSET_H+i*WBCALENDARCONTROL_DAY_WIDTH,NSHeight(tBounds)-WBCALENDARCONTROL_WEEK_OFFSET_V-WBCALENDARCONTROL_OFFSET_V,WBCALENDARCONTROL_DAY_WIDTH,WBCALENDARCONTROL_WEEK_OFFSET_V);
        
        tString=dayArray[(firstDayOfWeek+i)%7];
        
        tSize=[tString sizeWithAttributes:dayOfWeekAttributes];
		
        [tString drawAtPoint:NSMakePoint(NSMidX(tRect)-tSize.width*0.5+2,NSMinY(tRect)+2) 
              withAttributes:dayOfWeekAttributes];
    }
    
    // Draw the days
    
    for(i=firstday;i<42;i++)
    {
        if (monthday[i]>0)
        {
            [self drawday:i];
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

@end
