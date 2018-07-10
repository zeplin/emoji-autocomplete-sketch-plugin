//
//  ZPLSuggestion.m
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "ZPLSuggestion.h"

@implementation ZPLSuggestion

- (instancetype)initWithEmoji:(ZPLEmoji *)emoji alias:(NSString *)alias {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _emoji = emoji;
    _alias = [alias copy];
    
    return self;
}

@end
