//
//  ZPLFocusTableView.h
//  Autocomplete
//
//  Created by Yigitcan Yurtsever on 29.06.2018.
//  Copyright © 2018 Zeplin, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ZPLFocusTableViewDelegate;

@interface ZPLFocusTableView : NSTableView

@end

@protocol ZPLFocusTableViewDelegate <NSTableViewDelegate>
@optional

- (void)tableView:(NSTableView *)tableView didClickRow:(NSInteger)row;

@end
