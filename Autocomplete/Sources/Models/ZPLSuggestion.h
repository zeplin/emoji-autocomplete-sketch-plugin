//
//  ZPLSuggestion.h
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZPLEmoji;

@interface ZPLSuggestion : NSObject

@property (strong, nonatomic) ZPLEmoji *emoji;
@property (copy, nonatomic) NSString *alias;

- (instancetype)initWithEmoji:(ZPLEmoji *)emoji alias:(NSString *)alias;

@end
