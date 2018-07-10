//
//  NSColor+Autocomplete.m
//  Autocomplete
//
//  Created by K. Berk Cebi on 7/9/18.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "NSColor+Autocomplete.h"

@implementation NSColor (Autocomplete)

+ (NSColor *)zpl_selectionColor {
    return [NSColor colorWithDeviceRed:105.0f / 255.0f green:155.0f / 255.0f blue:228.0f / 255.0f alpha:1.0f];
}

@end
