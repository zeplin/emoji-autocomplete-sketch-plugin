//
//  ZPLSuggestionWindowController.h
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZPLSuggestion;

@protocol ZPLSuggestionWindowControllerDelegate;

@interface ZPLSuggestionWindowController : NSWindowController

@property (weak, nonatomic) id <ZPLSuggestionWindowControllerDelegate> delegate;

- (void)presentWithSuggestions:(NSArray<ZPLSuggestion *> *)suggestions positioningTextView:(NSTextView *)positioningTextView;
- (void)dismiss;

@end

@protocol ZPLSuggestionWindowControllerDelegate <NSObject>

- (void)suggestionWindowController:(ZPLSuggestionWindowController *)suggestionWindowController didSelectSuggestion:(ZPLSuggestion *)suggestion;
- (NSRange)suggestionWindowController:(ZPLSuggestionWindowController *)suggestionWindowController keywordRangeForTextView:(NSTextView *)textView;

@end
