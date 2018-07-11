//
//  NSView+Autocomplete.m
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 10.07.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "NSView+Autocomplete.h"

@implementation NSView (Autocomplete)

- (BOOL)zpl_nextRespondersContainClassFromNames:(NSArray<NSString *> *)classNames {
    for (NSResponder *nextResponder = self.nextResponder; nextResponder; nextResponder = nextResponder.nextResponder) {
        for (NSString *className in classNames) {
            if ([nextResponder isKindOfClass:NSClassFromString(className)]) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
