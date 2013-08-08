//
//  NSNotificationCenter+NotaflictionMonitor.m
//
//  Created by Theo Ireton on 2013/08/08.
//  Copyright (c) 2013 HackerShack. All rights reserved.
//

#import "NSNotificationCenter+NotaflictionMonitor.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSNotificationCenter (NotaflictionMonitor)

// only bother capturing data if we have this enabled
#ifdef NFL_ENABLED

// how many items (for this framework) should we grab off the stack?
#define STACK_TRACE_DEPTH 6

// ignore warnings about reimplementation of methods
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

// MethodSwizzling by Mike Ash
void MethodSwizzle(Class c, SEL original, SEL new)
{
    Method originalMethod = class_getInstanceMethod(c, original);
    Method newMethod = class_getInstanceMethod(c, new);
    
    if(class_addMethod(c, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
    {
        class_replaceMethod(c, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}
+ (void)load
{
    // swap out our methods for the original ones
    MethodSwizzle(self, @selector(addObserver:selector:name:object:), @selector(override_addObserver:selector:name:object:));
    MethodSwizzle(self, @selector(postNotification:), @selector(override_postNotification:));
    MethodSwizzle(self, @selector(postNotificationName:object:), @selector(override_postNotificationName:object:));
    MethodSwizzle(self, @selector(postNotificationName:object:userInfo:), @selector(override_postNotificationName:object:userInfo:));
    MethodSwizzle(self, @selector(removeObserver:), @selector(override_removeObserver:));
    MethodSwizzle(self, @selector(removeObserver:name:object:), @selector(override_removeObserver:name:object:));

    #if NS_BLOCKS_AVAILABLE
        MethodSwizzle(self, @selector(addObserverForName:object:queue:usingBlock:), @selector(override_addObserverForName:object:queue:usingBlock:));
    #endif
}

// override all the observation methods for logging purposes
- (void)override_addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject
{
    // grab a stack trace for the last X framework calls
    NSArray *traceData = [Notafliction stackTrace:STACK_TRACE_DEPTH];
    
    // only add to record if we have events for the framework on the stack
    if(traceData.count > 0)
    {
        // add to record
        NSDictionary *record = [NSDictionary dictionaryWithObjectsAndKeys:
                                NSStringFromSelector(aSelector), @"selector",
                                aName, @"name",
                                [anObject class], @"objectclass",
                                observer, @"observer"
                                , nil];
        
        [Notafliction logEvent:@"addObserver_selector_name_object" withRecord:record andTraceData:traceData];
    }
    
    // send notification to NSNotificationCenter
    [self override_addObserver:observer selector:aSelector name:aName object:anObject];
}

- (void)override_postNotification:(NSNotification *)notification
{
    // grab a stack trace for the last X framework calls
    NSArray *traceData = [Notafliction stackTrace:STACK_TRACE_DEPTH];
    
    // only add to record if we have events for the framework on the stack
    if(traceData.count > 0)
    {
        // add to record
        NSDictionary *record = [NSDictionary dictionaryWithObjectsAndKeys:
                                notification.name, @"notification"
                                , nil];
        
        [Notafliction logEvent:@"postNotification" withRecord:record andTraceData:traceData];
    }
    
    // send notification to NSNotificationCenter
    [self override_postNotification:notification];
}

- (void)override_postNotificationName:(NSString *)aName object:(id)anObject
{
    // grab a stack trace for the last X framework calls
    NSArray *traceData = [Notafliction stackTrace:STACK_TRACE_DEPTH];
    
    // only add to record if we have events for the framework on the stack
    if(traceData.count > 0)
    {
        // add to record
        NSDictionary *record = [NSDictionary dictionaryWithObjectsAndKeys:
                                aName, @"name",
                                [anObject class], @"objectclass"
                                , nil];
        
        [Notafliction logEvent:@"postNotificationName_object" withRecord:record andTraceData:traceData];
    }
    
    // send notification to NSNotificationCenter
    [self override_postNotificationName:aName object:anObject];
}

- (void)override_postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    // grab a stack trace for the last X framework calls
    NSArray *traceData = [Notafliction stackTrace:STACK_TRACE_DEPTH];
    
    // only add to record if we have events for the framework on the stack
    if(traceData.count > 0)
    {
        // add to record
        NSDictionary *record = [NSDictionary dictionaryWithObjectsAndKeys:
                                aName, @"name",
                                [anObject class], @"objectclass",
                                [NSString stringWithFormat:@"%@", aUserInfo], @"userinfo"
                                , nil];
        
        [Notafliction logEvent:@"postNotificationName_object_userInfo" withRecord:record andTraceData:traceData];
    }
    
    // send notification to NSNotificationCenter
    [self override_postNotificationName:aName object:anObject userInfo:aUserInfo];
}

- (void)override_removeObserver:(id)observer
{
    // grab a stack trace for the last X framework calls
    NSArray *traceData = [Notafliction stackTrace:STACK_TRACE_DEPTH];
    
    // only add to record if we have events for the framework on the stack
    if(traceData.count > 0)
    {
        // add to record
        NSDictionary *record = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%@", observer], @"observer"
                                , nil];
        
        [Notafliction logEvent:@"removeObserver" withRecord:record andTraceData:traceData];
    }
    
    // send notification to NSNotificationCenter
    [self override_removeObserver:observer];
}

- (void)override_removeObserver:(id)observer name:(NSString *)aName object:(id)anObject
{
    // grab a stack trace for the last X framework calls
    NSArray *traceData = [Notafliction stackTrace:STACK_TRACE_DEPTH];
    
    // only add to record if we have events for the framework on the stack
    if(traceData.count > 0)
    {
        // add to record
        NSDictionary *record = [NSDictionary dictionaryWithObjectsAndKeys:
                                aName, @"name",
                                [anObject class], @"objectclass",
                                [NSString stringWithFormat:@"%@", observer], @"observer"
                                , nil];
        
        [Notafliction logEvent:@"removeObserver" withRecord:record andTraceData:traceData];
    }
    
    // send notification to NSNotificationCenter
    [self override_removeObserver:observer name:aName object:anObject];
}

 #if NS_BLOCKS_AVAILABLE
 
 - (id)override_addObserverForName:(NSString *)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block NS_AVAILABLE(10_6, 4_0)
 {
     // grab a stack trace for the last X framework calls
     NSArray *traceData = [Notafliction stackTrace:STACK_TRACE_DEPTH];
     
     // only add to record if we have events for the framework on the stack
     if(traceData.count > 0)
     {
         // add to record
         NSDictionary *record = [NSDictionary dictionaryWithObjectsAndKeys:
                                 name, @"name",
                                 [obj class], @"objectclass",
                                 [NSString stringWithFormat:@"%@", queue], @"queue"
                                 , nil];
         
         [Notafliction logEvent:@"addObserverForName_object_queue_block" withRecord:record andTraceData:traceData];
     }
     
     // return data from notification center
     return [self override_addObserverForName:name object:obj queue:queue usingBlock:block];
 }
 
 #endif


#pragma clang diagnostic pop

#endif
@end
