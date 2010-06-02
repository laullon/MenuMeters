//
//  MMCPUProcess.h
//  MenuMeters
//
//  Created by German Laullon on 27/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <libproc.h>

@interface MMCPUProcess : NSObject {
	NSNumber *proc_cpu;
	NSNumber *sys_time;
	NSNumber *CPU;
	NSNumber *pid;
	NSString *name;
}

+(MMCPUProcess *)initWithPid:(NSNumber *)p;
-(void)setPid:(NSNumber *)p;
-(NSNumber *)pid;
-(bool)upadteCPUUsage;
-(NSNumber *)CPU;
-(NSString *)CPUUsage;
-(NSString *)name;
-(NSComparisonResult)cpuUsageCompare:(MMCPUProcess *)other;

@end
