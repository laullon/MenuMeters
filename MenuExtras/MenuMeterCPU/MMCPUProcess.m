//
//  MMCPUProcess.m
//  MenuMeters
//
//  Created by German Laullon on 27/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MMCPUProcess.h"


@implementation MMCPUProcess

+(MMCPUProcess *)initWithPid:(NSNumber *)p{
	MMCPUProcess *process=[[self alloc] init];
	[process setPid:[p retain]];
	return process;
}

-(void)setPid:(NSNumber *)p{
	pid=[p retain];
	
	ProcessSerialNumber psn = {0, kNoProcess};

	if(!GetProcessForPID ([pid intValue],&psn)){
		NSDictionary *info = (NSDictionary *)ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
		name=[[info objectForKey:(NSString *)kCFBundleNameKey] retain];
	}
}

-(NSNumber *)pid{
	return pid;
}

- (bool)upadteCPUUsage{
	struct proc_taskinfo pti;
	struct timeval tv;
	
	if(proc_cpu==nil){
		proc_cpu=[NSNumber numberWithUnsignedLongLong:0];
		sys_time=[NSNumber numberWithUnsignedLongLong:0];
	}
	
    gettimeofday(&tv, NULL);
	int rsize=proc_pidinfo([pid intValue], PROC_PIDTASKINFO, 0, &pti, sizeof(pti));
	if (rsize <= 0) {
		return NO;
	}
	
	NSNumber *sys_time2=[NSNumber numberWithUnsignedLongLong:((tv.tv_sec*1000000L)+tv.tv_usec)];
	double sys_diff=(double)[sys_time2 unsignedLongLongValue]-[sys_time unsignedLongLongValue];
	sys_time=[sys_time2 retain];
	
	NSNumber *proc_cpu2=[NSNumber numberWithUnsignedLongLong:(pti.pti_total_user + pti.pti_total_system)/10]; // deberia ser 1000 pero lo dejo en 10 para ahorrarme luego multiplicar por 100
	double proc_diff=(double)[proc_cpu2 unsignedLongLongValue]-[proc_cpu unsignedLongLongValue];
	proc_cpu=[proc_cpu2 retain];
	
	CPU=[NSNumber numberWithDouble:(proc_diff/sys_diff)];	
	
    return YES;	
}

-(NSNumber *)CPU{
	return CPU;
}

-(NSString *)CPUUsage{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormat:@"##0.0"];
	return [NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:CPU]];
}

-(NSString *)name{
	return name;
}

-(NSComparisonResult)cpuUsageCompare:(MMCPUProcess *)other{
	return [[other CPU] compare:CPU];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"%@ - %@",name,[self CPUUsage]];
}


@end
