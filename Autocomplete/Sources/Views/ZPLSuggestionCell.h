//
//  ZPLSuggestionCell.h
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZPLSuggestion;

@interface ZPLSuggestionCell : NSTableCellView

@property (strong, nonatomic) ZPLSuggestion *suggestion;

+ (CGFloat)height;
+ (NSString *)reuseIdentifier;

@end
