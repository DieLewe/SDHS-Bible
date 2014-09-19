//
//  BookmarkTableViewController.h
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 06/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "GeneralModel.h"
#import "ReadViewController.h"

@interface BookmarkTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tblBookmarks;
    NSMutableArray *bookmarks;
    GeneralModel *generalModel;
    ReadViewController *destination;
}

@property (strong, nonatomic) UITableView *tblBookmarks;
@property (strong, nonatomic) NSMutableArray *bookmarks;

@end
