//
//  ZPLEmojiController.m
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "ZPLEmojiController.h"

#import "ZPLAutocompletePluginController.h"

@implementation ZPLEmojiController

#pragma mark - Initializers

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[ZPLAutocompletePluginController class]];
    NSString *emojiListPath = [bundle pathForResource:@"Emojis" ofType:@"plist"];
    NSArray<NSDictionary *> *emojiDictionaries = (NSArray<NSDictionary *> *)[NSArray arrayWithContentsOfFile:emojiListPath];
    
    NSMutableArray<ZPLEmoji *> *emojis = [NSMutableArray array];
    for (NSDictionary *emojiDictionary in emojiDictionaries) {
        ZPLEmoji *emoji = [[ZPLEmoji alloc] initWithDictionary:emojiDictionary];
        
        if (!emoji) {
            continue;
        }
        
        [emojis addObject:emoji];
    }
    
    self.emojis = emojis;
    
    return self;
}

@end
