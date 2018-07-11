//
//  NSView+Autocomplete.h
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 10.07.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Autocomplete)

- (BOOL)zpl_nextRespondersContainClassFromNames:(NSArray<NSString *> *)classNames;

@end
