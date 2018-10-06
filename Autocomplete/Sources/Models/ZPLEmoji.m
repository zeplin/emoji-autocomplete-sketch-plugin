//
//  ZPLEmoji.m
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
