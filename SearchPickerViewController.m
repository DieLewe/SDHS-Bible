//
//  SearchPickerViewController.m
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 06/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import "SearchPickerViewController.h"

@interface SearchPickerViewController ()

@end

@implementation SearchPickerViewController

@synthesize btnOpenBible, pickLocation;

NSString *bookSelected;

NSInteger bookSelectedNumber, chapterSelectedNumber, verseSelectedNumber, bookCurrentNumber, chapterCurrentNumber;
NSArray *allProperties;
NSString *partFlag;
bool stuffChangedPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *) filePath {
    return [generalModel filePath];
}

- (void) openDB {
    //    [generalModel openDB];
    NSLog(@"~~~ openDB");
    //---get the path to the database file---
    NSString *dbFileName = [self filePath];
    NSString *filePath = @"";
    
    //---if the database can be found---
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbFileName]) {
        filePath = dbFileName;
    }
    else {
        filePath = [[NSBundle mainBundle] pathForResource:@"sdhs_bible" ofType:@"sql"];
    }
    
    //---create database---
    if (sqlite3_open([filePath UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(0, @"Database failed to open.");
    }
}

- (void) getProperties {
    allProperties = [generalModel getProperties];
    partFlag = [allProperties objectAtIndex:0];
    tableName = [allProperties objectAtIndex:1];
    alignRight = [allProperties objectAtIndex:2];
    fontName = [allProperties objectAtIndex:3];
    fontSize = [[allProperties objectAtIndex:4] intValue];
    Choice = [allProperties objectAtIndex:5];
    //    NSLog(@"ALL PROPERTIES: %@", allProperties);
}

//---number of components in the Picker view---
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    NSLog(@"Inside numberOfComponentsInPickerView");
	return 2; //3 for verses
}

//---number of items(rows) in the Picker view---
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    NSLog(@"Start pickerView");
    [self getProperties];
    if (!bookSelectedNumber) {
        bookSelectedNumber = bookCurrentNumber;
    }
    
    NSInteger tempBookNumber = [generalModel bookOrder:bookSelectedNumber];
    
    if (([partFlag isEqualToString:@"NT"]) && (tempBookNumber <= 39)) {
        tempBookNumber = 40;
    }
    else if (([partFlag isEqualToString:@"OT"]) && (tempBookNumber >= 40)) {
        tempBookNumber = 1;
    }
    
    NSInteger result = 0;
	if (component == 0) {
        NSLog(@"NUMComponent: %d", component);
        NSLog(@"PARTFLAG-=-=-=-=-=-=-=-=: %@", partFlag);
        if ([partFlag isEqualToString:@"NT"]) {
            result = 27;
        }
        else if ([partFlag isEqualToString:@"OT"]) {
            result = 39;
        }
        else {
            result = 66;
        }
        NSLog(@"RESULT-=-=-=-=-=-=-=-=: %d", result);
    }
    else if (component == 1) {
        NSLog(@"NUMComponent: %d", component);
        NSString *qsql = @"";
        qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND verseNr = 1", tableName, tempBookNumber];
        
        NSLog(@"qsQL: %@", qsql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                result++;
            }
        }
        else {
            NSLog(@"HELP, I can't connect to the DATABASE!");
        }
        //---deletes the compiled statement from memory---
        sqlite3_finalize(statement);
        NSLog(@"NUMComponent RESULT: %d, %d", component, result);
    }
    
    NSLog(@"End pickerView");
    return result;
}

//---populating the Picker view---
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSLog(@"Start pickerView Populate");
    [self getProperties];
    NSLog(@"POPComponent: %d, Row: %d", component, row);
	if (component == 0) {
        NSInteger varNT = 0;
        NSInteger tempBookNumber;
        if ([partFlag isEqualToString:@"NT"]) {
            tempBookNumber = row + 1;
            varNT = 39;
        }
        else {
            tempBookNumber = [generalModel bookOrder:(row + 1)];
        }
        NSLog(@"???tempBOOKNUMBER: %d", tempBookNumber);
        return [generalModel loadBookname:tempBookNumber + varNT];
    }
	else {
        //        NSLog(@"chapterNumber: %d",row + 1);
        return [NSString stringWithFormat:@"%d", row + 1];
    }
    NSLog(@"End pickerView Populate");
}

//---the item selected by the user---
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Start pickerView Selected");
    [self getProperties];
    NSLog(@"SELComponent: %d, Row: %d", component, row);
    bookSelectedNumber = bookCurrentNumber;
    chapterSelectedNumber = chapterCurrentNumber;
    stuffChangedPicker = FALSE;
    NSInteger varNT = 0;
    if ([partFlag isEqualToString:@"NT"]) {
        varNT = 39;
    }
    if (component == 0) {
        NSLog(@"COMP 0");
        bookSelected = [generalModel loadBookname:row + 1 + varNT];
        bookSelectedNumber = row + 1 + varNT;
        [thePickerView reloadComponent:1];
        chapterSelectedNumber = [thePickerView selectedRowInComponent:1] + 1;
    }
    else if (component == 1) {
        NSLog(@"COMP 1");
        bookSelectedNumber = [thePickerView selectedRowInComponent:0] + 1 + varNT;
        chapterSelectedNumber = row + 1;
    }
    NSLog(@"+++++++++++++BOOKSELECTEDNUMBER: %d", bookSelectedNumber);
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d", bookSelectedNumber] forKey:@"bookSelectedNumber"];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d", chapterSelectedNumber] forKey:@"chapterSelected"];
    
    [thePickerView reloadAllComponents];
    NSLog(@"DONE WITH COMPONENT: %d", component);
    NSLog(@"End pickerView Selected");
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    destination = [[ReadViewController alloc] init];
    UITabBarController *tbc = [segue destinationViewController];
    destination = (ReadViewController *)[[tbc customizableViewControllers] objectAtIndex:0];
    destination.bookNumberPicked = [NSString stringWithFormat:@"%d", bookSelectedNumber];
    destination.chapterNumberPicked = [NSString stringWithFormat:@"%d", chapterSelectedNumber ];
}

- (void) setLocation:(NSMutableArray *) locationArray:(NSString *) turnPage {
    [generalModel setLocation:locationArray :turnPage];
}

- (IBAction)btnOpenBible:(id)sender {
    NSLog(@"Start btnOpenBible");
    bookSelectedNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bookSelectedNumber"] intValue];
    chapterSelectedNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:@"chapterSelected"] intValue];
    
    //---prepare the location and then store it---
    NSString *locationNewCurrent, *locationNewPrevious, *locationNewNext, *locationNewPreAmble;
    
    locationNewPreAmble = [NSString stringWithFormat:@"%02d", (bookSelectedNumber)];
    if (((bookSelectedNumber) <= 39) && ((bookSelectedNumber) >= 1)) {
        locationNewPreAmble = [locationNewPreAmble stringByAppendingString:@"Otabkey"];
    }
    else {
        if (((bookSelectedNumber) >= 40) && ((bookSelectedNumber) <= 66)) {
            locationNewPreAmble = [locationNewPreAmble stringByAppendingString:@"Ntabkey"];
        }
    }
    locationNewCurrent = [[locationNewPreAmble stringByAppendingFormat:@"%dtabkey", chapterSelectedNumber] stringByAppendingFormat:@"%d", verseSelectedNumber];
    locationNewPrevious = [[locationNewPreAmble stringByAppendingFormat:@"%dtabkey", chapterSelectedNumber - 1] stringByAppendingFormat:@"%d", verseSelectedNumber];
    locationNewNext = [[locationNewPreAmble stringByAppendingFormat:@"%dtabkey", chapterSelectedNumber + 1] stringByAppendingFormat:@"%d", verseSelectedNumber];
    NSMutableArray *locationNewArray = [NSMutableArray arrayWithObjects:locationNewPrevious, locationNewCurrent, locationNewNext, nil];
    [self getProperties];
    [self setLocation:locationNewArray:@"same"];
//    [self getTextFromTable:@"same"];
    
    NSLog(@"End btnOpenBible");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    generalModel = [[GeneralModel alloc] init];
    [self openDB];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [btnOpenBible release];
    [pickLocation release];
    [generalModel release];
    [destination release];
    sqlite3_close(db);
    [super dealloc];
}
@end
