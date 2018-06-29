//
//  ZPLAutocompletePluginController.m
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "ZPLAutocompletePluginController.h"

#import "ZPLSuggestionController.h"

@interface ZPLAutocompletePluginController ()

@property (strong, nonatomic) ZPLSuggestionController *suggestionController;

@end

@implementation ZPLAutocompletePluginController

#pragma mark - Singleton

+ (instancetype)sharedController {
    static dispatch_once_t once;
    static id _sharedInstance = nil;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Getters & Setters

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) {
        return;
    }
    
    _enabled = enabled;
    
    if (enabled) {
        self.suggestionController = [[ZPLSuggestionController alloc] init];
    } else {
        self.suggestionController = nil;
    }
}

@end
