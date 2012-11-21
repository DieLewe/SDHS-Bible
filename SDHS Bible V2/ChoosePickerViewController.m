//
//  ChoosePickerViewController.m
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 06/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import "ChoosePickerViewController.h"

@interface ChoosePickerViewController ()

@end

@implementation ChoosePickerViewController

@synthesize pickBible, btnChooseBible;

NSString *partFlag, *bibleSelected;
NSArray *allProperties;
NSMutableArray *bibles;
NSInteger bookSelectedNumber, bookCurrentNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (NSInteger) bookOrder: (NSInteger) bookToCheck {
    return [generalModel bookOrder:bookToCheck];
}

//---number of components in the Picker view---
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
//    NSLog(@"Inside numberOfComponentsInPickerView");
	return 1;
}

//---number of items(rows) in the Picker view---
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
//    NSLog(@"Inside pickerView");
    return [bibles count];
}

//---populating the Picker view---
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NSLog(@"Inside pickerView Populate");
    return [bibles objectAtIndex:row];
}

//---the item selected by the user---
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    NSLog(@"Inside pickerView Selected");
    bibleSelected = [bibles objectAtIndex:row];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    destination = [[ReadViewController alloc] init];
    UITabBarController *tbc = [segue destinationViewController];
    destination = (ReadViewController *)[[tbc customizableViewControllers] objectAtIndex:0];
    destination.biblePicked = bibleSelected;
}

- (IBAction)btnChooseBibleClicked:(id)sender {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    generalModel = [[GeneralModel alloc] init];
    //Get the language choice from the plist file.
    NSInteger pickMyRow = 0;
    [self getProperties];
    
    bibles = [[NSMutableArray alloc] init];
    [bibles addObject:@"עִבְרִית תַּנַייךְ"];//Hebrew Tanakh
    [bibles addObject:@"ייִדיש תנך"];//Yiddish Tanakh
    [bibles addObject:@"עִבְרִית הברית החדשה"];//Hebrew New Testament
    [bibles addObject:@"English"];//English KJV
    
    for (NSInteger i = 0; i < [bibles count]; i++) {
        NSLog(@"BIBLE AT INDEX %d: %@; and Choice is: %@", i, [bibles objectAtIndex:i], Choice);
        NSString *myBiblePicked = [bibles objectAtIndex:i];
        if ([Choice isEqualToString:myBiblePicked]) {
            pickMyRow = i;
        }
    }
    NSLog(@"PICK ROW %d", pickMyRow);
    [pickBible selectRow:pickMyRow inComponent:0 animated:YES];
    [pickBible reloadAllComponents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [destination release];
    [bibles release];
    [bibleSelected release];
    [pickBible release];
    [btnChooseBible release];
    [generalModel release];
    [super dealloc];
}
@end
