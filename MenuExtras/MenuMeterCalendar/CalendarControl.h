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

#import <AppKit/AppKit.h>

@interface CalendarControl : NSControl
{
	NSCalendarDate *currentDate;
    BOOL newdate;
    id target;
    SEL action;
    int firstday;
    int firstDayOfWeek;
    NSDictionary *normalAttributes;
    NSDictionary *dayOfWeekAttributes;
	NSDictionary *otherMonthAttributes;
	IBOutlet NSTextField* month;
}

- (NSDate *) date;
- (void)setDate:(NSDate *) aDate;

- (int)drawday:(NSDate *)aDay col:(int)col row:(int)row;

- (void)setAction:(SEL) aAction;
- (void)setTarget:(id) aTarget;

- (NSDate *)getFirstDayOfCalendar;

- (IBAction) prevMonth: sender;
- (IBAction) nextMonth: sender;

@end
