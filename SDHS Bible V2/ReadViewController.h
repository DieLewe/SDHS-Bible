//
//  SDHSBibleViewController.h
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 06/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "GeneralModel.h"

//@class ChooseViewController;

@interface ReadViewController : UIViewController {
    sqlite3 *db;
    UITextView *textView1;
    UILabel *lblLocation;
    UIButton *btnBookmark;
    NSString *tableName, *alignRight, *fontName;
    NSInteger fontSize;
    GeneralModel *generalModel;
}

@property (strong, nonatomic) IBOutlet UITextView *textView1;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) NSString *biblePicked, *bookNumberPicked, *chapterNumberPicked, *bookmarkPicked;
@property (strong, nonatomic) IBOutlet UIButton *btnBookmark;

- (IBAction)pinchDetected:(UIPinchGestureRecognizer *)sender;

- (void) getTextFromTable: (NSString *) turnPage;

@end
