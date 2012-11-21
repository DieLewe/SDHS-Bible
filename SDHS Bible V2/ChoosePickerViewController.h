//
//  ChoosePickerViewController.h
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 06/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "GeneralModel.h"
#import "ReadViewController.h"

@interface ChoosePickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    sqlite3 *db;
    UIPickerView *pickBible;
    UIButton *btnChooseBible;
    NSString *tableName, *alignRight, *fontName, *Choice;
    NSInteger fontSize;
    GeneralModel *generalModel;
    ReadViewController *destination;
}

@property (strong, nonatomic) IBOutlet UIPickerView *pickBible;
@property (strong, nonatomic) IBOutlet UIButton *btnChooseBible;
@property (strong, nonatomic) NSMutableArray *bibles;

- (IBAction)btnChooseBibleClicked:(id)sender;

@end
