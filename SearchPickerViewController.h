//
//  SearchPickerViewController.h
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 06/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "GeneralModel.h"
#import "ReadViewController.h"

@interface SearchPickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    sqlite3 *db;
    UIPickerView *pickLocation;
    UIButton *btnOpenBible;
    NSString *tableName, *alignRight, *fontName, *Choice;
    NSInteger fontSize;
    GeneralModel *generalModel;
    ReadViewController *destination;
}

@property (strong, nonatomic) IBOutlet UIButton *btnOpenBible;
@property (strong, nonatomic) IBOutlet UIPickerView *pickLocation;

@end
