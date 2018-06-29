//
//  ZPLSuggestionCell.m
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "ZPLSuggestionCell.h"

#import "ZPLEmoji.h"
#import "ZPLSuggestion.h"

static const CGFloat ZPLSuggestionCellHeight = 40.0f;
static const CGFloat ZPLSuggestionCellEmojiLeftMargin = 8.0f;
static const CGFloat ZPLSuggestionCellAliasLeftPadding = 5.0f;
static const CGFloat ZPLSuggestionCellAliasRightMargin = -5.0f;

@interface ZPLSuggestionCell ()

@property (strong, nonatomic) NSTextField *emojiTextField;
@property (strong, nonatomic) NSTextField *aliasTextField;

@end

@implementation ZPLSuggestionCell

+ (CGFloat)height {
    return ZPLSuggestionCellHeight;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([ZPLSuggestionCell class]);
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.identifier = [[self class] reuseIdentifier];
    
    _emojiTextField = [[NSTextField alloc] init];
    _emojiTextField.bordered = NO;
    _emojiTextField.drawsBackground = NO;
    _emojiTextField.editable = NO;
    _emojiTextField.usesSingleLineMode = YES;
    _emojiTextField.selectable = NO;
    _emojiTextField.font = [NSFont systemFontOfSize:15.0];
    [_emojiTextField setContentCompressionResistancePriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_emojiTextField setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    _aliasTextField = [[NSTextField alloc] init];
    _aliasTextField.bordered = NO;
    _aliasTextField.drawsBackground = NO;
    _aliasTextField.editable = NO;
    _aliasTextField.usesSingleLineMode = YES;
    _aliasTextField.selectable = NO;
    _aliasTextField.alignment = NSTextAlignmentLeft;
    _aliasTextField.font = [NSFont systemFontOfSize:13.0];
    [_aliasTextField setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_aliasTextField setContentHuggingPriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    [self addSubview:_emojiTextField];
    [self addSubview:_aliasTextField];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _emojiTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _aliasTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [_emojiTextField.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:ZPLSuggestionCellEmojiLeftMargin],
        [_emojiTextField.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_aliasTextField.leftAnchor constraintEqualToAnchor:_emojiTextField.rightAnchor constant:ZPLSuggestionCellAliasLeftPadding],
        [_aliasTextField.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:ZPLSuggestionCellAliasRightMargin],
        [_aliasTextField.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-1.0f]
    ]];
    
    return self;
}

#pragma mark - Properties

- (void)setSuggestion:(ZPLSuggestion *)suggestion {
    _suggestion = suggestion;
    
    self.emojiTextField.stringValue = suggestion.emoji.value;
    self.aliasTextField.stringValue = suggestion.alias;
}

@end
