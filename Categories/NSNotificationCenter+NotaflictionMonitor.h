//
//  NSNotificationCenter+NotaflictionMonitor.h
//
//  Created by Theo Ireton on 2013/08/08.
//  Copyright (c) 2013 HackerShack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (NotaflictionMonitor)
    void MethodSwizzle(Class c, SEL orig, SEL new);
@end
