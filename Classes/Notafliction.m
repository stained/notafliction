//
//  NotaflictionUtils.m
//
//  Created by Theo Ireton on 2013/08/08.
//  Copyright (c) 2013 HackerShack. All rights reserved.
//

#import "Notafliction.h"

@implementation Notafliction

// a place to keep track of notifications
NSMutableArray *_notificationRecord;

// if we're looking for all framework notifications
#ifndef NFL_FRAMEWORK
    #define NFL_FRAMEWORK nil
#endif

+ (NSArray *)stackTrace:(NSInteger)depth;
{
    NSMutableArray *traceArray = [[NSMutableArray alloc] init];
    
    // start from 3rd message in stack trace
    // first being this method and second being the one that called this.
    for(int i = 2; i < [NSThread callStackSymbols].count; i++)
    {
        NSArray *separated = [self findAndSeparateTraceAtIndex:i];
        
        NSString *frameworkFromTrace = [separated objectAtIndex:1];
        
        // ignore everything but framework notifications, or don't ignore if not defined
        if(!NFL_FRAMEWORK || [frameworkFromTrace isEqualToString:NFL_FRAMEWORK])
        {
            
//            NSLog(@"%@", separated);
            
            // build up trace
            NSMutableDictionary *trace = [[NSMutableDictionary alloc] init];
            trace[@"framework"] = frameworkFromTrace;
            trace[@"memoryAddress"] = [separated objectAtIndex:2];
            
            int count = separated.count;
            
            switch(count)
            {
                case 5:
                    trace[@"class"] = frameworkFromTrace;
                    trace[@"method"] = [separated objectAtIndex:3];
                    trace[@"linenumber"] = [separated objectAtIndex:4];
                    break;
                    
                case 6:
                    trace[@"class"] = [separated objectAtIndex:3];
                    trace[@"method"] = [separated objectAtIndex:4];
                    trace[@"linenumber"] = [separated objectAtIndex:4];
                    break;
                    
                case 8:
                    trace[@"class"] = [separated objectAtIndex:4];
                    trace[@"method"] = [separated objectAtIndex:5];
                    trace[@"linenumber"] = [separated objectAtIndex:7];
                    break;
            }
            
            // don't want to add our monitor in the trace
            if(![trace[@"class"] isEqualToString:@"NSNotificationCenter(NotaflictionMonitor)"])
            {
                // add for return
                [traceArray addObject:trace];
            }
        }
        
        if(traceArray.count == depth)
        {
            break;
        }
    }

    return traceArray;
}

+ (NSArray *)findAndSeparateTraceAtIndex:(NSInteger)index
{
    NSString *traceData = [[NSThread callStackSymbols] objectAtIndex:index];
    
    NSCharacterSet *separator = [NSCharacterSet characterSetWithCharactersInString:@" .,-+[]?"];
    NSMutableArray *separated = [NSMutableArray arrayWithArray:[traceData componentsSeparatedByCharactersInSet:separator]];
    
    // remove empty strings
    [separated removeObject:@""];
    
    return separated;
}

+ (void)logEvent:(NSString *)event withRecord:(NSDictionary *)record andTraceData:(NSArray *)traceData
{
    if(!_notificationRecord)
    {
        _notificationRecord = [[NSMutableArray alloc] init];
    }
    
    NSDictionary *completeRecord = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @([[NSDate date] timeIntervalSince1970]), @"timestamp",
                                    event, @"event",
                                    record, @"record",
                                    traceData, @"stacktrace"
                                    , nil];
    
    [_notificationRecord addObject:completeRecord];
}

+ (void)publishEventRecord
{
#ifdef NFL_ENABLED
    // publish notification record
    NSLog(@"%@", _notificationRecord);
#endif
}



@end
