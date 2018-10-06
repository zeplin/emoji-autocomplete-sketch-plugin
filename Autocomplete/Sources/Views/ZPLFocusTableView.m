//
//  ZPLFocusTableView.m
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
