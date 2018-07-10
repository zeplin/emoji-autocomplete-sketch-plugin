//
//  ZPLEmoji.m
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "ZPLEmoji.h"

NSString * const ZPLEmojiAliasSeparator = @"_";

static NSString * const ZPLEmojiValueDictionaryKey = @"emoji";
static NSString * const ZPLEmojiAliasesDictionaryKey = @"aliases";
static NSString * const ZPLEmojiUnicodeVersionDictionaryKey = @"unicode_version";

static const NSOperatingSystemVersion ZPLEmojiUnicode8OperationSystemVersion = {.majorVersion = 10, .minorVersion = 11, .patchVersion = 5};
static const NSOperatingSystemVersion ZPLEmojiUnicode9OperationSystemVersion = {.majorVersion = 10, .minorVersion = 12, .patchVersion = 2};

@implementation ZPLEmoji

+ (BOOL)supportsUnicodeVersion:(NSString *)unicodeVersion {
    NSMutableArray<NSString *> *supportedUnicodeVersions = [NSMutableArray arrayWithArray:@[@"", @"3.0", @"3.2", @"4.0", @"4.1", @"5.1", @"5.2", @"6.0", @"6.1", @"7.0"]];
    
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ZPLEmojiUnicode8OperationSystemVersion]) {
        [supportedUnicodeVersions addObject:@"8.0"];
    }
    
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ZPLEmojiUnicode9OperationSystemVersion]) {
        [supportedUnicodeVersions addObject:@"9.0"];
    }
    
    return [supportedUnicodeVersions containsObject:unicodeVersion];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSString *value = (NSString *)[dictionary objectForKey:ZPLEmojiValueDictionaryKey];
    NSArray<NSString *> *aliases = (NSArray<NSString *> *)[dictionary objectForKey:ZPLEmojiAliasesDictionaryKey];
    NSString *unicodeVersion = (NSString *)[dictionary objectForKey:ZPLEmojiUnicodeVersionDictionaryKey];
    
    if (!value || !aliases || aliases.count == 0 || !unicodeVersion || ![ZPLEmoji supportsUnicodeVersion:unicodeVersion]) {
        return nil;
    }
    
    _value = [value copy];
    _aliases = aliases;
    
    return self;
}

@end
