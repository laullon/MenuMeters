//
//  MenuMeterMemStats.m
//
// 	Reader object for VM info
//
//	Copyright (c) 2002-2009 Alex Harper
//
// 	This file is part of MenuMeters.
// 
// 	MenuMeters is free software; you can redistribute it and/or modify
// 	it under the terms of the GNU General Public License version 2 as 
//  published by the Free Software Foundation.
// 
// 	MenuMeters is distributed in the hope that it will be useful,
// 	but WITHOUT ANY WARRANTY; without even the implied warranty of
// 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// 	GNU General Public License for more details.
// 
// 	You should have received a copy of the GNU General Public License
// 	along with MenuMeters; if not, write to the Free Software
// 	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
// 

#import "MenuMeterMemStats.h"


///////////////////////////////////////////////////////////////
//	
//	Private methods and constants
//
///////////////////////////////////////////////////////////////

// Default strings for swap file login
#define kDefaultSwapPath		@"/private/var/vm/"
#define kDefaultSwapPrefix		@"swapfile"

@interface MenuMeterMemStats (PrivateMethods)
- (void)initializeSwapPath;
@end


///////////////////////////////////////////////////////////////
//	
//	Backwards compatibility
//
///////////////////////////////////////////////////////////////

// Swap structure from Tiger sysctl header, we hardcode here for older SDKs
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_4
struct xsw_usage {
	u_int64_t	xsu_total;
	u_int64_t	xsu_avail;
	u_int64_t	xsu_used;
	u_int32_t	xsu_pagesize;
	boolean_t	xsu_encrypted;
};
#endif


///////////////////////////////////////////////////////////////
//	
//	init/dealloc
//
///////////////////////////////////////////////////////////////

@implementation MenuMeterMemStats

- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}

	// Tiger or later?
	SInt32 gestValue = 0;
	if ((Gestalt(gestaltSystemVersion, &gestValue) == noErr) && (gestValue >= 0x1040)) {
		isTigerOrLater = YES;
	}
	
	// Build the Mach host reference
	selfHost = mach_host_self();
	if (!selfHost) {
		[self release];
		return nil;
	}
	
	// Paging indicator patch contributed by Bernhard Baehr.
	// Initialize lastpageins and lastpageouts
	[self memStats];

	return self;
	
} // init

- (void)dealloc {
	
	[swapPath release];
	[swapPrefix release];
	[super dealloc];

} // dealloc


///////////////////////////////////////////////////////////////
//	
//	 Mem usage info 
//
///////////////////////////////////////////////////////////////

- (NSDictionary *)memStats {
	
	// Get the data
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t vmCount = HOST_VM_INFO_COUNT;
	if (host_statistics(selfHost, HOST_VM_INFO, (host_info_t)&vmStats, &vmCount) != KERN_SUCCESS) {
		return nil;
	}
	
	// Do deltas dealing with wraparound. On older OS versions the structure
	// was typdefed as signed, but apparently treated as unsigned by the kernel.
	// In newer OS versions its unsigned 32 or 64 bit (natural_t). Try to
	// deal with all cases.
	uint64_t deltaPageIn = 0, deltaPageOut = 0;
	if ((natural_t)vmStats.pageins >= lastPageIn) {
		deltaPageIn = (natural_t)vmStats.pageins - lastPageIn;
	} else {
#ifdef __LP64__	
		// 64-bit rollover? Nothing sane we can do
		deltaPageIn = (natural_t)vmStats.pageins;
#else
		deltaPageIn = (natural_t)vmStats.pageins + (UINT_MAX - lastPageIn + 1);
#endif
	}	
	if ((natural_t)vmStats.pageouts >= lastPageOut) {
		deltaPageOut = (natural_t)vmStats.pageouts - lastPageOut;
	} else {
#ifdef __LP64__	
		// 64-bit rollover? Nothing sane we can do
		deltaPageOut = (natural_t)vmStats.pageouts;
#else
		deltaPageOut = (natural_t)vmStats.pageouts + (UINT_MAX - lastPageOut + 1);
#endif
	}
	// Update history
	lastPageIn = vmStats.pageins;
	lastPageOut = vmStats.pageouts;
	
	// Build total RAM if needed (check everytime just in case we've had earlier
	// errors). Double casts prevent sign extension from applying to upsized
	// 32-bit signed.
	totalRAM =  ((uint64_t)((natural_t)vmStats.free_count) + 
					(uint64_t)((natural_t)vmStats.active_count) + 
					(uint64_t)((natural_t)vmStats.inactive_count) + 
					(uint64_t)((natural_t)vmStats.wire_count)) * (uint64_t)vm_page_size;

	// The rest of the statistics
	uint64_t active = (uint64_t)((natural_t)vmStats.active_count) * (uint64_t)((natural_t)vm_page_size);
	uint64_t inactive = (uint64_t)((natural_t)vmStats.inactive_count) * (uint64_t)((natural_t)vm_page_size);
	uint64_t wired = (uint64_t)((natural_t)vmStats.wire_count) * (uint64_t)((natural_t)vm_page_size);
	uint64_t free = (uint64_t)((natural_t)vmStats.free_count) * (uint64_t)((natural_t)vm_page_size);
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithDouble:(double)totalRAM / 1048576], @"totalmb",
				// There has been much confusion amongst users over what "Used" and "Free" meant.
				// In older versions "Used" included inactive pages, which tends to grow
				// over time from lazy reclamation. This led to reports of "leaks".
				// Current implementation seems to better match actual expectations.
				// Because this includes inactive pages in "Used" folks thought that they were leaking
				[NSNumber numberWithDouble:(double)(free + inactive) / 1048576], @"freemb",
				[NSNumber numberWithDouble:(double)(active + wired) / 1048576], @"usedmb",
				[NSNumber numberWithDouble:(double)active / 1048576], @"activemb",
				[NSNumber numberWithDouble:(double)inactive / 1048576], @"inactivemb",
				[NSNumber numberWithDouble:(double)wired / 1048576], @"wiremb",
				[NSNumber numberWithDouble:(double)free / 1048576], @"freepagemb",
				// Again, double casts to block sign extension
				[NSNumber numberWithUnsignedLongLong:(uint64_t)((natural_t)vmStats.hits)], @"hits",
				[NSNumber numberWithUnsignedLongLong:(uint64_t)((natural_t)vmStats.lookups)], @"lookups",
				[NSNumber numberWithUnsignedLongLong:(uint64_t)((natural_t)vmStats.pageins)], @"pageins",
				[NSNumber numberWithUnsignedLongLong:(uint64_t)((natural_t)vmStats.pageouts)], @"pageouts",
				[NSNumber numberWithUnsignedLongLong:(uint64_t)((natural_t)vmStats.faults)], @"faults",
				[NSNumber numberWithUnsignedLongLong:(uint64_t)((natural_t)vmStats.cow_faults)], @"cowfaults",
				[NSNumber numberWithUnsignedLongLong:(uint64_t)deltaPageIn], @"deltapageins",
				[NSNumber numberWithUnsignedLongLong:(uint64_t)deltaPageOut], @"deltapageouts",
				nil];
	
} // memStats

- (NSDictionary *)swapStats {
	
	// Set up the swap path if its not already. We used to do this in the init,
	// but that occassionally crashed on load. So now we defer as much as possible
	if (!swapPath) {
		[self initializeSwapPath];
		if (!swapPath) return nil;
	}
	
	// Does the path exist? How many files?
	uint32_t swapCount = 0;
	uint64_t swapSize = 0;
	BOOL isDir = NO;
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:swapPath isDirectory:&isDir] && isDir) {
		// Iterate the directory looking for swaps
		NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:swapPath];
		NSString *currentFile = nil;
		while ((currentFile = [dirEnum nextObject])) {
			NSString *currentFileFullPath = [swapPath stringByAppendingPathComponent:currentFile];
			if ([currentFile hasPrefix:swapPrefix] && 
					[fm fileExistsAtPath:currentFileFullPath isDirectory:&isDir] &&
					!isDir) {
				swapCount++;
				swapSize += [[[fm fileAttributesAtPath:currentFileFullPath	
										  traverseLink:NO]
								objectForKey:NSFileSize] unsignedLongLongValue];
			}
		}
	}
	
	if (swapCount > peakSwapFiles) {
		peakSwapFiles = swapCount;
	}
	
	// On Tiger and later get swap usage and encryption, based on patch from
	// Michael Nordmeyer (http://goodyworks.com)
	BOOL encrypted = NO;
	uint64_t swapUsed = 0;
	if (isTigerOrLater) {
		int	swapMIB[] = { CTL_VM, 5 };
		struct xsw_usage swapUsage;
		size_t swapUsageSize = sizeof(swapUsage);
		memset(&swapUsage, 0, sizeof(swapUsage));
		if (sysctl(swapMIB, 2, &swapUsage, &swapUsageSize, NULL, 0) == 0) {
			encrypted = swapUsage.xsu_encrypted ? YES : NO;
			swapUsed = swapUsage.xsu_used;
		}
	}

	return [NSDictionary dictionaryWithObjectsAndKeys:
				swapPath, @"swappath",
				[NSNumber numberWithUnsignedInt:swapCount], @"swapcount",
				[NSNumber numberWithUnsignedInt:peakSwapFiles], @"swapcountpeak",
				[NSNumber numberWithUnsignedLongLong:swapSize / 1048576], @"swapsizemb",
				[NSNumber numberWithUnsignedLongLong:swapUsed / 1048576], @"swapusedmb",
				[NSNumber numberWithBool:encrypted], @"swapencrypted",
				nil];
	
} // swapStats

///////////////////////////////////////////////////////////////
//	
//	Private methods
//
///////////////////////////////////////////////////////////////

- (void)initializeSwapPath {
	
	// We need to figure out where the swap file is. This information
	// is not published by dynamic_pager to sysctl. We can't get dynamic_pager's
	// arg list directed using sysctl because its UID 0. So we have to do some
	// parsing of ps -axww output to get the info.
	NSTask *psTask = [[[NSTask alloc] init] autorelease];
	[psTask setLaunchPath:@"/bin/ps"];
	[psTask setArguments:[NSArray arrayWithObjects:@"-axww", nil]];
	NSPipe *psPipe = [[[NSPipe alloc] init] autorelease];
	[psTask setStandardOutput:psPipe];
	NSFileHandle *psHandle = [psPipe fileHandleForReading];
	
	// Do the launch in an exception block. Old style block for 10.2 compatibility.
	// Accumulate all results into a single string for parse.
	NSMutableString *psOutput = [[@"" mutableCopy] autorelease];
	NSMutableString *swapFullPath = [NSMutableString string];
	BOOL taskLaunched = NO;
	NS_DURING
		[psTask launch];
		while ([psTask isRunning]) {
			[psOutput appendString:[[[NSString alloc] initWithData:[psHandle availableData] 
														   encoding:NSUTF8StringEncoding] autorelease]];
			usleep(250000);
		}
	NS_HANDLER
		// Catch
		NSLog(@"MenuMeterMemStats unable to launch '/bin/ps'.");
		taskLaunched = NO;
		psOutput = nil;
	NS_ENDHANDLER
	if (psOutput) {
		NSArray *psSplit = [psOutput componentsSeparatedByString:@"\n"];
		NSEnumerator *psLineWalk = [psSplit objectEnumerator];
		NSString *psLine = nil;
		while ((psLine = [psLineWalk nextObject])) {
			NSArray *psArgSplit = [psLine componentsSeparatedByString:@" "];
			if (([psArgSplit containsObject:@"dynamic_pager"] || [psArgSplit containsObject:@"/sbin/dynamic_pager"]) &&
					[psArgSplit containsObject:@"-F"]) {
				// Consume all arguments till the next arg. This would fail
				// on the path "/my/silly -swappath/" but is that really something
				// we need to worry about?
				for (CFIndex argIndex = [psArgSplit indexOfObject:@"-F"] + 1; argIndex < [psArgSplit count]; argIndex++) {
					NSString *currentArg = [psArgSplit objectAtIndex:argIndex];
					if ([currentArg hasPrefix:@"-"]) break;
					if ([swapFullPath length]) [swapFullPath appendString:@" "];
					[swapFullPath appendString:currentArg];
				}
			}
			if (![swapFullPath isEqualToString:@""]) break;
		}
	}

	// Did we get it?
	if (![swapFullPath isEqualToString:@""]) {
		swapPath = [[swapFullPath stringByDeletingLastPathComponent] retain];
		swapPrefix = [[swapFullPath lastPathComponent] retain];
	}
	else {
		NSLog(@"MenuMeterMemStats unable to locate dynamic_pager args. Assume default.");
		swapPath = [kDefaultSwapPath retain];
		swapPrefix = [kDefaultSwapPrefix retain];
	}

} // initializeSwapPath

@end
