//
//  BookmarkTableViewController.m
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 06/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import "BookmarkTableViewController.h"
#import "BookmarkTableViewCell.h"

@interface BookmarkTableViewController ()

@end

@implementation BookmarkTableViewController

@synthesize tblBookmarks, bookmarks;

NSArray *allProperties;
NSMutableArray *BookmarksPlist, *BookmarksPlistText;

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
    BookmarksPlist = [allProperties objectAtIndex:6];
    BookmarksPlistText = [allProperties objectAtIndex:7];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellBookmark";
    
    //---try to get a reusable cell---
    BookmarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    int row = [indexPath row];
    
    [[cell textLabel] setText:bookmarks[row]];

    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    destination = [[ReadViewController alloc] init];
    UITabBarController *tbc = [segue destinationViewController];
    destination = (ReadViewController *) [[tbc customizableViewControllers] objectAtIndex:0];
    NSIndexPath *myIndexPath = [tblBookmarks indexPathForSelectedRow];
    
    NSInteger row = [myIndexPath row];
    
    destination.bookmarkPicked = bookmarks[row];
//    NSLog(@"BOOKMARKPICKED %@", destination.bookmarkPicked);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    bookmarks = [[NSMutableArray alloc] init];
    [bookmarks removeAllObjects];
    [self getProperties];
    [bookmarks addObjectsFromArray:BookmarksPlistText];
    [tblBookmarks reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ViewLOADED");
    generalModel = [[GeneralModel alloc] init];
	// Do any additional setup after loading the view.
    bookmarks = [[NSMutableArray alloc] init];
    [self getProperties];
    [bookmarks addObjectsFromArray:BookmarksPlistText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [bookmarks release];
    [tblBookmarks release];
    [destination release];
    [generalModel release];
    [super dealloc];
}
@end
