//
//  ZPLSuggestionController.m
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "ZPLSuggestionController.h"

#import "ZPLEmoji.h"
#import "ZPLSuggestion.h"
#import "ZPLEmojiController.h"
#import "ZPLSuggestionWindowController.h"

static NSString * const ZPLSuggestionDelimeter = @":";
static NSString * const MSTextLayerTextViewClassName = @"MSTextLayerTextView";

@interface ZPLSuggestionController () <ZPLSuggestionWindowControllerDelegate>

@property (strong, nonatomic) ZPLEmojiController *emojiController;
@property (strong, nonatomic) ZPLSuggestionWindowController *windowController;

@property (strong, nonatomic) NSCharacterSet *invertedCharacterSet;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:nil];
    
    return self;
}

#pragma mark - Private

- (void)reloadSuggestionsForTextView:(NSTextView *)textView {
    NSArray<ZPLSuggestion *> *suggestions = [self suggestionsForTextView:textView];
    
    if (suggestions.count == 0) {
        [self.windowController dismiss];
        self.windowController = nil;
        
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
    if (![notification.object isKindOfClass:NSClassFromString(MSTextLayerTextViewClassName)]) {
        return;
    }
    
    NSTextView *textView = (NSTextView *)notification.object;
    
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
    NSString *replacement = [NSString stringWithFormat:@"%@ ", suggestion.emoji.value];
    [[self.positioningTextView textStorage] replaceCharactersInRange:keywordRange withString:replacement];
}

- (NSRange)suggestionWindowController:(ZPLSuggestionWindowController *)suggestionWindowController keywordRangeForTextView:(NSTextView *)textView {
    return [self keywordRangeForTextView:textView];
}

@end
