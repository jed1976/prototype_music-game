//
//  NSMutableArray+Randomization.m
//  Prototype1
//
//  Created by Joe Dakroub on 7/29/12.
//  Copyright (c) 2012 Joe Dakroub. All rights reserved.
//

#import "NSMutableArray+Randomization.h"

@implementation NSMutableArray (Randomization)

- (void)shuffle
{
    for (uint i = 0; i < self.count; ++i)
    {
        int nElements = self.count - i;
        int n = arc4random_uniform(nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
