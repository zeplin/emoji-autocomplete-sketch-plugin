//
//  ZPLSuggestionWindowController.m
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

#import "ZPLSuggestionWindowController.h"

#import "ZPLSuggestion.h"
#import "ZPLFocusTableView.h"
#import "ZPLSuggestionCell.h"
#import "ZPLRowView.h"
#import "NSColor+Autocomplete.h"

static const CGFloat ZPLSuggestionWindowControllerContentViewCornerRadius = 3.0f;
static const CGFloat ZPLSuggestionWindowControllerMargin = 8.0f;

static const NSUInteger ZPLEventKeyCodeReturn = 36;
static const NSUInteger ZPLEventKeyCodeTab = 48;
static const NSUInteger ZPLEventKeyCodeEscape = 53;
static const NSUInteger ZPLEventKeyCodeBottomArrow = 125;
static const NSUInteger ZPLEventKeyCodeTopArrow = 126;

static const NSSize ZPLSuggestionWindowControllerMaximumWindowSize = {.width = 190.0f, .height = 208.0f};

@interface ZPLSuggestionWindowController () <NSTableViewDataSource, NSTableViewDelegate, ZPLFocusTableViewDelegate>

@property (copy, nonatomic) NSArray<ZPLSuggestion *> *suggestions;

@property (strong, nonatomic) ZPLFocusTableView *tableView;

@property (strong, nonatomic) id mouseDownMonitor;
@property (strong, nonatomic) id keyDownMonitor;

@end

@implementation ZPLSuggestionWindowController

#pragma mark - Initializers

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;

    if (_keyDownMonitor != nil) {
        [NSEvent removeMonitor:_keyDownMonitor];
    }

    if (_mouseDownMonitor != nil) {
        [NSEvent removeMonitor:_mouseDownMonitor];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super initWithWindow:nil];
    if (!self) {
        return nil;
    }

    NSView *contentView = [[NSView alloc] init];
    contentView.wantsLayer = YES;
    contentView.layer.cornerRadius = ZPLSuggestionWindowControllerContentViewCornerRadius;

    _tableView = [[ZPLFocusTableView alloc] init];
    _tableView.headerView = nil;
    _tableView.intercellSpacing = NSZeroSize;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsEmptySelection = NO;

    NSColor *tableViewBackgroundColor = [NSColor zpl_backgroundColor];
    if (tableViewBackgroundColor) {
        _tableView.backgroundColor = tableViewBackgroundColor;
    }

    NSScrollView *scrollView = [[NSScrollView alloc] init];
    scrollView.documentView = _tableView;

    [contentView addSubview:scrollView];

    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        [scrollView.leftAnchor constraintEqualToAnchor:contentView.leftAnchor],
        [scrollView.rightAnchor constraintEqualToAnchor:contentView.rightAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor]
    ]];

    NSTableColumn *column = [[NSTableColumn alloc] init];
    column.resizingMask = NSTableColumnAutoresizingMask;
    [_tableView addTableColumn:column];

    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    window.titleVisibility = NSWindowTitleHidden;
    window.hasShadow = YES;
    window.opaque = NO;
    window.backgroundColor = [NSColor clearColor];
    window.contentView = contentView;

    self.window = window;

    return self;
}

#pragma mark - Public

- (void)presentWithSuggestions:(NSArray<ZPLSuggestion *> *)suggestions positioningTextView:(NSTextView *)positioningTextView {
    self.suggestions = suggestions;

    [self.tableView reloadData];

    if (![self adjustFrameWithPositioningTextView:positioningTextView]) {
        return;
    }

    if (self.window.isVisible == NO) {
        [positioningTextView.window addChildWindow:self.window ordered:NSWindowAbove];

        __weak typeof(self) weakSelf = self;

        if (!self.keyDownMonitor) {
            self.keyDownMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent *(NSEvent *event) {
                __strong typeof(weakSelf) strongSelf = weakSelf;

                switch (event.keyCode) {
                    case ZPLEventKeyCodeTab:
                    case ZPLEventKeyCodeReturn: {
                        NSInteger selectedRow = strongSelf.tableView.selectedRow;

                        if (selectedRow < 0) {
                            return nil;
                        }

                        [strongSelf.delegate suggestionWindowController:strongSelf didSelectSuggestion:strongSelf.suggestions[selectedRow]];

                        return nil;
                    } break;

                    case ZPLEventKeyCodeEscape: {
                        [strongSelf dismiss];

                        return nil;
                    } break;

                    case ZPLEventKeyCodeTopArrow: {
                        BOOL isCommand = (event.modifierFlags & NSCommandKeyMask) == NSCommandKeyMask;

                        NSInteger row = isCommand ? 0 : MAX(strongSelf.tableView.selectedRow - 1, 0);
                        [strongSelf selectRowAtIndex:row];

                        return nil;
                    } break;

                    case ZPLEventKeyCodeBottomArrow: {
                        BOOL isCommand = (event.modifierFlags & NSCommandKeyMask) == NSCommandKeyMask;

                        NSInteger lastRow = strongSelf.suggestions.count - 1;
                        NSInteger row = isCommand ? lastRow : MIN(strongSelf.tableView.selectedRow + 1, lastRow);
                        [strongSelf selectRowAtIndex:row];

                        return nil;
                    } break;

                    default: {
                        return event;
                    } break;
                }
            }];
        }

        if (!self.mouseDownMonitor) {
            self.mouseDownMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown | NSEventMaskOtherMouseDown handler:^ NSEvent *(NSEvent *event) {
                __strong typeof(weakSelf) strongSelf = weakSelf;

                if (strongSelf.window == event.window) {
                    return event;
                }

                if (positioningTextView.window != event.window) {
                    [strongSelf dismiss];

                    return event;
                }

                NSPoint point = [positioningTextView convertPoint:event.locationInWindow fromView:nil];

                if (!NSPointInRect(point, positioningTextView.bounds)) {
                    [strongSelf dismiss];

                    return nil;
                }

                return event;
            }];
        }

        positioningTextView.postsFrameChangedNotifications = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positioningTextViewFrameDidChange:) name:NSViewFrameDidChangeNotification object:positioningTextView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parentWindowDidResignKey:) name:NSWindowDidResignKeyNotification object:positioningTextView.window];
    }

    [self selectRowAtIndex:0];
}

- (void)dismiss {
    if (self.window.isVisible == NO) {
        return;
    }

    if (self.keyDownMonitor != nil) {
        [NSEvent removeMonitor:self.keyDownMonitor];
        self.keyDownMonitor = nil;
    }

    if (self.mouseDownMonitor != nil) {
        [NSEvent removeMonitor:self.mouseDownMonitor];
        self.mouseDownMonitor = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.window.parentWindow removeChildWindow:self.window];
    [self.window orderOut:nil];
}

#pragma mark - Private

- (BOOL)adjustFrameWithPositioningTextView:(NSTextView *)positioningTextView {
    if (self.window == nil || positioningTextView.superview == nil || positioningTextView.window == nil) {
        return NO;
    }

    CGFloat windowHeight = MIN(self.suggestions.count * ZPLSuggestionCell.height, ZPLSuggestionWindowControllerMaximumWindowSize.height);

    NSRange keywordRange = [self.delegate suggestionWindowController:self keywordRangeForTextView:positioningTextView];
    if (keywordRange.location == NSNotFound) {
        keywordRange = [positioningTextView selectedRange];
    }

    NSRange glyphRange = [[positioningTextView layoutManager] glyphRangeForCharacterRange:keywordRange actualCharacterRange:nil];
    NSRect characterRect = [[positioningTextView layoutManager] boundingRectForGlyphRange:glyphRange inTextContainer:[positioningTextView textContainer]];
    characterRect = NSInsetRect(characterRect, positioningTextView.textContainerOrigin.x, positioningTextView.textContainerOrigin.y);
    NSRect positioningTextViewRect = [positioningTextView convertRect:characterRect toView:nil];
    NSRect rect = [positioningTextView.window convertRectToScreen:positioningTextViewRect];

    rect.origin.y = rect.origin.y - windowHeight - ZPLSuggestionWindowControllerMargin;
    rect.size.width = ZPLSuggestionWindowControllerMaximumWindowSize.width;
    rect.size.height = windowHeight;

    CGFloat screenMaxX = NSMaxX(positioningTextView.window.screen.frame);
    CGFloat minX = ZPLSuggestionWindowControllerMargin;
    CGFloat maxX = screenMaxX - ZPLSuggestionWindowControllerMargin;

    if (NSMaxX(rect) > maxX) {
        rect.origin.x = maxX - rect.size.width;
    } else if (NSMinX(rect) < minX) {
        rect.origin.x = minX;
    }

    [self.window setFrame:rect display:NO];

    return YES;
}

- (void)selectRowAtIndex:(NSInteger)index {
    if (self.suggestions.count == 0) {
        return;
    }

    NSInteger adjustedIndex = MAX(0, MIN(index, self.suggestions.count - 1));

    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:adjustedIndex] byExtendingSelection:NO];
    [self.tableView scrollRowToVisible:adjustedIndex];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.suggestions.count;
}

#pragma mark - ZPLFocusTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ZPLSuggestionCell *cell = [tableView makeViewWithIdentifier:[ZPLSuggestionCell reuseIdentifier] owner:self];
    if (!cell) {
        cell = [[ZPLSuggestionCell alloc] init];
    }

    cell.suggestion = self.suggestions[row];

    return cell;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return [ZPLSuggestionCell height];
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[ZPLRowView alloc] init];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return YES;
}

- (void)tableView:(NSTableView *)tableView didClickRow:(NSInteger)row {
    [self.delegate suggestionWindowController:self didSelectSuggestion:self.suggestions[row]];
}

#pragma mark - Notifications

- (void)positioningTextViewFrameDidChange:(NSNotification *)notification {
    NSTextView *positioningTextView = notification.object;
    if (!positioningTextView) {
        return;
    }

    [self adjustFrameWithPositioningTextView:positioningTextView];
}

- (void)parentWindowDidResignKey:(NSNotification *)notification {
    [self dismiss];
}

@end
