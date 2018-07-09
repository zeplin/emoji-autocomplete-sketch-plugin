//
//  ZPLFocusTableView.m
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import "ZPLFocusTableView.h"

@interface ZPLFocusTableView ()

@property (strong, nonatomic) NSTrackingArea *trackingArea;

@end

@implementation ZPLFocusTableView

#pragma mark - NSTableView

- (void)reloadData {
    [super reloadData];
    
    if (!self.window) {
        return;
    }
    
    [self reloadSelectionWithMouseLocationInWindow:self.window.mouseLocationOutsideOfEventStream];
}

#pragma mark - NSResponder

- (void)updateTrackingAreas {
    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseMoved | NSTrackingActiveInActiveApp owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
    
    [super updateTrackingAreas];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint convertedLocation = [self convertPoint:event.locationInWindow toView:nil];
    NSInteger row = [self rowAtPoint:convertedLocation];
    
    id <ZPLFocusTableViewDelegate> delegate = (id <ZPLFocusTableViewDelegate>)self.delegate;
    if (row >= 0 && [delegate respondsToSelector:@selector(tableView:didClickRow:)]) {
        [delegate tableView:self didClickRow:row];
    }
}

- (void)mouseMoved:(NSEvent *)event {
    [self reloadSelectionWithMouseLocationInWindow:event.locationInWindow];
}

#pragma mark - Private

- (void)reloadSelectionWithMouseLocationInWindow:(NSPoint)mouseLocationInWindow {
    NSPoint convertedLocation = [self convertPoint:mouseLocationInWindow toView:nil];
    NSInteger row = [self rowAtPoint:convertedLocation];
    
    if (row < 0 || self.selectedRow == row) {
        return;
    }
    
    BOOL shouldSelect = [self.delegate tableView:self shouldSelectRow:row] ?: YES;
    
    if (shouldSelect) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    }
}

@end
