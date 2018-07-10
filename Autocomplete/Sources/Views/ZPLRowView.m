//
//  ZPLRowView.m
//  Autocomplete
//
//  Created by K. Berk Cebi on 7/9/18.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "ZPLRowView.h"

#import "NSColor+Autocomplete.h"

@implementation ZPLRowView

#pragma mark - ZPLRowView

- (NSBackgroundStyle)interiorBackgroundStyle {
    return self.isSelected ? NSBackgroundStyleDark : NSBackgroundStyleLight;
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    [[NSColor zpl_selectionColor] setFill];
    
    [[NSBezierPath bezierPathWithRect:self.bounds] fill];
}

@end
