//
//  NotaflictionUtils.h
//
//  Created by Theo Ireton on 2013/08/08.
//  Copyright (c) 2013 HackerShack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSNotificationCenter+NotaflictionMonitor.h"

@interface Notafliction : NSObject

+ (NSArray *)stackTrace:(NSInteger)depth;
+ (void)logEvent:(NSString *)event withRecord:(NSDictionary *)record andTraceData:(NSArray *)traceData;
+ (void)publishEventRecord;

@end
