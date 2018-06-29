//
//  ZPLEmoji.h
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ZPLEmojiAliasSeparator;

@interface ZPLEmoji : NSObject

@property (strong, nonatomic) NSArray<NSString *> *aliases;
@property (copy, nonatomic) NSString *value;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
