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
static NSString * const ZPLEmojiTagsDictionaryKey = @"tags";
static NSString * const ZPLEmojiUnicodeVersionDictionaryKey = @"unicode_version";
static NSString * const ZPLEmojiCategoryDictionaryKey = @"category";
static NSString * const ZPLEmojiFlagsCategoryDictionaryValue = @"Flags";

static NSString * const ZPLEmojiFlagTag = @"flag";

static const NSOperatingSystemVersion ZPLEmojiUnicode8OperationSystemVersion = {.majorVersion = 10, .minorVersion = 11, .patchVersion = 5};
static const NSOperatingSystemVersion ZPLEmojiUnicode9OperationSystemVersion = {.majorVersion = 10, .minorVersion = 12, .patchVersion = 2};
static const NSOperatingSystemVersion ZPLEmojiUnicode10OperationSystemVersion = {.majorVersion = 10, .minorVersion = 13, .patchVersion = 1};
static const NSOperatingSystemVersion ZPLEmojiUnicode11OperationSystemVersion = {.majorVersion = 10, .minorVersion = 14, .patchVersion = 1};
static const NSOperatingSystemVersion ZPLEmojiUnicode12OperationSystemVersion = {.majorVersion = 10, .minorVersion = 15, .patchVersion = 1};
static const NSOperatingSystemVersion ZPLEmojiUnicode13OperationSystemVersion = {.majorVersion = 11, .minorVersion = 3, .patchVersion = 0};
static const NSOperatingSystemVersion ZPLEmojiUnicode14OperationSystemVersion = {.majorVersion = 12, .minorVersion = 3, .patchVersion = 0};

@implementation ZPLEmoji

+ (BOOL)supportsUnicodeVersion:(NSString *)unicodeVersion {
    NSMutableArray<NSString *> *supportedUnicodeVersions = [NSMutableArray arrayWithArray:@[@"", @"3.0", @"3.2", @"4.0", @"4.1", @"5.1", @"5.2", @"6.0", @"6.1", @"7.0"]];

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ZPLEmojiUnicode8OperationSystemVersion]) {
        [supportedUnicodeVersions addObject:@"8.0"];
    }

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ZPLEmojiUnicode9OperationSystemVersion]) {
        [supportedUnicodeVersions addObject:@"9.0"];
    }

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ZPLEmojiUnicode10OperationSystemVersion]) {
        [supportedUnicodeVersions addObject:@"10.0"];
    }

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ZPLEmojiUnicode11OperationSystemVersion]) {
        [supportedUnicodeVersions addObject:@"11.0"];
    }

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ZPLEmojiUnicode12OperationSystemVersion]) {
        [supportedUnicodeVersions addObject:@"12.0"];
        [supportedUnicodeVersions addObject:@"12.1"];
    }

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ZPLEmojiUnicode13OperationSystemVersion]) {
        [supportedUnicodeVersions addObject:@"13.0"];
        [supportedUnicodeVersions addObject:@"13.1"];
    }

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ZPLEmojiUnicode14OperationSystemVersion]) {
        [supportedUnicodeVersions addObject:@"14.0"];
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
    NSArray<NSString *> *tags = (NSArray<NSString *> *)[dictionary objectForKey:ZPLEmojiTagsDictionaryKey];
    NSString *unicodeVersion = (NSString *)[dictionary objectForKey:ZPLEmojiUnicodeVersionDictionaryKey];

    if (!value || !aliases || aliases.count == 0 || !unicodeVersion || ![ZPLEmoji supportsUnicodeVersion:unicodeVersion]) {
        return nil;
    }

    if (!tags) {
        tags = [NSArray array];
    }

    NSString *category = (NSString *)[dictionary objectForKey:ZPLEmojiCategoryDictionaryKey];

    if ([category isEqualToString:ZPLEmojiFlagsCategoryDictionaryValue] && ![tags containsObject:ZPLEmojiFlagTag]) {
        tags = [tags arrayByAddingObject:ZPLEmojiFlagTag];
    }

    _value = [value copy];
    _aliases = aliases;
    _tags = tags;

    return self;
}

@end
