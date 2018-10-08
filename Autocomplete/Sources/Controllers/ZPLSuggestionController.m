//
//  ZPLSuggestionController.m
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

#import "ZPLSuggestionController.h"

#import "ZPLEmoji.h"
#import "ZPLSuggestion.h"
#import "ZPLEmojiController.h"
#import "ZPLSuggestionWindowController.h"

#import "NSView+Autocomplete.h"

static NSString * const ZPLSuggestionDelimeter = @":";
static NSString * const MSTextLayerTextViewClassName = @"MSTextLayerTextView";
static NSString * const BCPageListViewControllerClassName = @"BCPageListViewController";
static NSString * const BCLayerListViewControllerClassName = @"BCLayerListViewController";
static NSString * const MSTextOverrideViewControllerClassName = @"MSTextOverrideViewController";

@interface ZPLSuggestionController () <ZPLSuggestionWindowControllerDelegate>

@property (strong, nonatomic) ZPLEmojiController *emojiController;
@property (strong, nonatomic) ZPLSuggestionWindowController *windowController;

@property (strong, nonatomic) NSCharacterSet *invertedCharacterSet;
@property (strong, nonatomic) NSArray<NSString *> *responderClassNames;

@property (strong, nonatomic) NSTextView *positioningTextView;

@end

@implementation ZPLSuggestionController

#pragma mark - Initializers

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _emojiController = [[ZPLEmojiController alloc] init];
    _invertedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789_"] invertedSet];
    _responderClassNames = @[BCPageListViewControllerClassName, BCLayerListViewControllerClassName, MSTextOverrideViewControllerClassName];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:nil];

    return self;
}

#pragma mark - Private

- (void)dismissWindowController {
    [self.windowController dismiss];
    self.windowController = nil;
}

- (void)reloadSuggestionsForTextView:(NSTextView *)textView {
    NSArray<ZPLSuggestion *> *suggestions = [self suggestionsForTextView:textView];

    if (suggestions.count == 0) {
        [self dismissWindowController];

        return;
    }

    if (!self.windowController) {
        self.windowController = [[ZPLSuggestionWindowController alloc] init];
        self.windowController.delegate = self;
    }

    self.positioningTextView = textView;
    [self.windowController presentWithSuggestions:suggestions positioningTextView:textView];
}

- (NSArray<ZPLSuggestion *> *)suggestionsForTextView:(NSTextView *)textView {
    NSRange keywordRange = [self keywordRangeForTextView:textView];

    if (keywordRange.location == NSNotFound) {
        return @[];
    }

    NSString *text = [textView.string lowercaseString];
    NSString *keyword = [text substringWithRange:keywordRange];
    NSMutableArray<ZPLSuggestion *> *suggestions = [NSMutableArray array];

    for (ZPLEmoji *emoji in self.emojiController.emojis) {
        for (NSString *alias in emoji.aliases) {
            if ([alias hasPrefix:keyword]) {
                ZPLSuggestion *suggestion = [[ZPLSuggestion alloc] init];
                suggestion.emoji = emoji;
                suggestion.alias = alias;

                [suggestions addObject:suggestion];

                continue;
            }

            NSArray<NSString *> *aliasComponents = [alias componentsSeparatedByString:ZPLEmojiAliasSeparator];

            if (aliasComponents.count <= 1) {
                continue;
            }

            for (NSString *aliasComponent in aliasComponents) {
                if ([aliasComponent hasPrefix:keyword]) {
                    ZPLSuggestion *suggestion = [[ZPLSuggestion alloc] init];
                    suggestion.emoji = emoji;
                    suggestion.alias = alias;

                    [suggestions addObject:suggestion];

                    break;
                }
            }
        }
    }

    return suggestions;
}

- (NSRange)keywordRangeForTextView:(NSTextView *)textView {
    if (textView.selectedRanges.firstObject == nil) {
        return NSMakeRange(NSNotFound, 0);
    }

    NSRange range = textView.selectedRanges.firstObject.rangeValue;

    if (range.length != 0) {
        return NSMakeRange(NSNotFound, 0);
    }

    NSString *text = [textView.string lowercaseString];
    NSString *leftText = [text substringToIndex:range.location];
    NSString *rightText = [text substringFromIndex:range.location];

    NSRange leftInvalidCharacterRange = [leftText rangeOfCharacterFromSet:self.invertedCharacterSet options:NSBackwardsSearch];
    if (leftInvalidCharacterRange.location == NSNotFound
        || ![[leftText substringWithRange:leftInvalidCharacterRange] isEqualToString:ZPLSuggestionDelimeter]) {
        return NSMakeRange(NSNotFound, 0);
    }

    NSUInteger rightInvalidCharacterIndex = [rightText rangeOfCharacterFromSet:self.invertedCharacterSet].location;
    if (rightInvalidCharacterIndex == NSNotFound) {
        rightInvalidCharacterIndex = rightText.length;
    }

    NSUInteger keywordLocation = leftInvalidCharacterRange.location + ZPLSuggestionDelimeter.length;
    NSUInteger keywordLength = range.location + rightInvalidCharacterIndex - keywordLocation;

    return NSMakeRange(keywordLocation, keywordLength);
}

#pragma mark - Notifications

- (void)textViewDidChangeSelection:(NSNotification *)notification {
    NSTextView *textView = (NSTextView *)notification.object;

    if (![textView isKindOfClass:NSClassFromString(MSTextLayerTextViewClassName)] &&
        ![textView zpl_nextRespondersContainClassFromNames:self.responderClassNames]) {
        [self dismissWindowController];

        return;
    }

    [self reloadSuggestionsForTextView:textView];
}

#pragma mark - ZPLSuggestionWindowControllerDelegate

- (void)suggestionWindowController:(ZPLSuggestionWindowController *)suggestionWindowController didSelectSuggestion:(ZPLSuggestion *)suggestion {
    if (!self.positioningTextView) {
        return;
    }

    NSRange keywordRange = [self keywordRangeForTextView:self.positioningTextView];

    if (keywordRange.location == NSNotFound) {
        return;
    }

    keywordRange = NSMakeRange(keywordRange.location - ZPLSuggestionDelimeter.length, keywordRange.length + ZPLSuggestionDelimeter.length);
    NSUInteger keywordMaxRange = NSMaxRange(keywordRange);

    BOOL hasWhitespaceSuffix = NO;
    if (keywordMaxRange < self.positioningTextView.string.length - 1) {
        NSString *nextCharacterString = [self.positioningTextView.string substringWithRange:NSMakeRange(keywordMaxRange, 1)];

        if ([nextCharacterString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound) {
            hasWhitespaceSuffix = YES;
        }
    }

    NSString *replacement;
    if (hasWhitespaceSuffix) {
        replacement = [suggestion.emoji.value copy];
    } else {
        replacement = [NSString stringWithFormat:@"%@ ", suggestion.emoji.value];
    }

    [[self.positioningTextView textStorage] replaceCharactersInRange:keywordRange withString:replacement];
}

- (NSRange)suggestionWindowController:(ZPLSuggestionWindowController *)suggestionWindowController keywordRangeForTextView:(NSTextView *)textView {
    return [self keywordRangeForTextView:textView];
}

@end
