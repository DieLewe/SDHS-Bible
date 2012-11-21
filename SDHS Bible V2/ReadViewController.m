//
//  SDHSBibleViewController.m
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 06/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import "ReadViewController.h"

@interface ReadViewController ()

@end

@implementation ReadViewController

@synthesize textView1, lblLocation;

NSString *partFlag, *stringFromTableTextNext, *stringFromTableText, *stringFromTableTextPrevious;
NSInteger bookCurrentNumber, chapterCurrentNumber, chapterSelectedNumber, verseCurrentNumber, verseSelectedNumber;
//NSMutableArray *bnames;
NSArray *allProperties;
bool plzChangeFontSize, bookOrderJewish;

- (NSString *) configPath {
    return [generalModel configPath];
}

- (NSString *) filePath {
    return [generalModel filePath];
}

- (void) openDB {
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

- (NSInteger) bookOrder: (NSInteger) bookToCheck {
    return [generalModel bookOrder:bookToCheck];
}

- (NSString *)loadBookname: (NSInteger) bookToLoad {
    return [generalModel loadBookname:bookToLoad];
}

- (void) alignText: (NSString *) side {
    if (side == @"left") {
        textView1.textAlignment = NSTextAlignmentLeft;
    }
	else if (side == @"right") {
        textView1.textAlignment = NSTextAlignmentRight;
    }
}

- (void) getProperties {
    allProperties = [generalModel getProperties];
    partFlag = [allProperties objectAtIndex:0];
    tableName = [allProperties objectAtIndex:1];
    alignRight = [allProperties objectAtIndex:2];
    fontName = [allProperties objectAtIndex:3];
    fontSize = [[allProperties objectAtIndex:4] intValue];
    if ([alignRight intValue] == 1) {
        [self alignText:@"right"];
    }
    else {
        [self alignText:@"left"];
    }
}

- (NSMutableArray *) getLocation {
    return [generalModel getLocation];
}

- (void) updateView {
    [self getProperties];
    NSInteger tempBookNumber = [self bookOrder:bookCurrentNumber];
    NSString *bookName = [self loadBookname:tempBookNumber];
    [lblLocation setText:[[bookName stringByAppendingString:@" "] stringByAppendingFormat:@"%d", chapterCurrentNumber]];
    [textView1 setText:stringFromTableText];
    [textView1 setContentOffset:CGPointMake(0,0)];
}

- (void) loadOtherPage: (NSString *) loadPage {
    if (loadPage == @"next") {
        stringFromTableTextNext = @"";
        //---Get the location to load, from the config file.---
        NSString *location = [[self getLocation] objectAtIndex:2];
        NSLog(@"-->loadnextPage: %@", location);
        NSArray *piecesArray = [location componentsSeparatedByString:@"\t"];
        bookCurrentNumber = [[piecesArray objectAtIndex:0] intValue];
        chapterCurrentNumber = [[piecesArray objectAtIndex:1] intValue];
        verseCurrentNumber = [[piecesArray objectAtIndex:2] intValue];
        
        if (!chapterSelectedNumber) {
            if (!chapterCurrentNumber) {
                chapterCurrentNumber = 1;
            }
            chapterSelectedNumber = chapterCurrentNumber;
        }
        if (!verseSelectedNumber) {
            if (!verseCurrentNumber) {
                verseCurrentNumber = 1;
            }
            verseSelectedNumber = verseCurrentNumber;
        }
        
        NSInteger tempBookNumber = [self bookOrder:bookCurrentNumber];
        
        //---retrieve rows---
        NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND chapterNr = %d", tableName, tempBookNumber, chapterCurrentNumber];
        NSLog(@"QSQL: %@", qsql);
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //---verse number
                char *tblVerseNrChr = (char *) sqlite3_column_text(statement, 4);
                NSString *tblVerseNrStr = [[NSString alloc] initWithUTF8String:tblVerseNrChr];
                
                //---text
                char *tblTextChr = (char *) sqlite3_column_text(statement, 5);
                NSString *tblTextStr = [[NSString alloc] initWithUTF8String:tblTextChr];
                
                if ([alignRight intValue] == 1) {
                    stringFromTableTextNext = [[[stringFromTableTextNext stringByAppendingFormat:@"\u202B%@ ", tblVerseNrStr] stringByAppendingString:tblTextStr] stringByAppendingString:@"\r\n"];
                }
                else {
                    stringFromTableTextNext = [[[[stringFromTableTextNext stringByAppendingString:tblVerseNrStr] stringByAppendingString:@" "] stringByAppendingString:tblTextStr] stringByAppendingString:@"\r\n"];
                }
                [tblVerseNrStr release];
                [tblTextStr release];
            }
            
            if ((stringFromTableTextNext == @"") || (stringFromTableTextNext == nil)) {
                //                [self alignText:@"left"];
                NSString *otherSection = @"";
                if ((bookCurrentNumber <= 66) && (bookCurrentNumber >= 40)) {
                    otherSection = @"New Testament";
                }
                else if ((bookCurrentNumber >= 1) && (bookCurrentNumber <= 39)) {
                    otherSection = @"Tanakh";
                }
                stringFromTableTextNext = [NSString stringWithFormat:@"Text not available in current translation. Please browse to %@ or load another language.", otherSection];
            }
            //---deletes the compiled statement from memory---
            sqlite3_finalize(statement);
        }
        [[NSUserDefaults standardUserDefaults]setObject:stringFromTableTextNext forKey:@"stringFromTableTextNext"];
    }
    else if (loadPage == @"previous") {
        stringFromTableTextPrevious = @"";
        //---Get the location to load, from the config file.---
        NSString *location = [[self getLocation] objectAtIndex:0];
        NSLog(@"-->loadpreviousPage: %@", location);
        NSArray *piecesArray = [location componentsSeparatedByString:@"\t"];
        bookCurrentNumber = [[piecesArray objectAtIndex:0] intValue];
        chapterCurrentNumber = [[piecesArray objectAtIndex:1] intValue];
        verseCurrentNumber = [[piecesArray objectAtIndex:2] intValue];
        
        if (!chapterSelectedNumber) {
            if (!chapterCurrentNumber) {
                chapterCurrentNumber = 1;
            }
            chapterSelectedNumber = chapterCurrentNumber;
        }
        if (!verseSelectedNumber) {
            if (!verseCurrentNumber) {
                verseCurrentNumber = 1;
            }
            verseSelectedNumber = verseCurrentNumber;
        }
        
        NSInteger tempBookNumber = [self bookOrder:bookCurrentNumber];
        
        //---retrieve rows---
        NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND chapterNr = %d", tableName, tempBookNumber, chapterCurrentNumber];
        NSLog(@"QSQL: %@", qsql);
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //---verse number
                char *tblVerseNrChr = (char *) sqlite3_column_text(statement, 4);
                NSString *tblVerseNrStr = [[NSString alloc] initWithUTF8String:tblVerseNrChr];
                
                //---text
                char *tblTextChr = (char *) sqlite3_column_text(statement, 5);
                NSString *tblTextStr = [[NSString alloc] initWithUTF8String:tblTextChr];
                
                if ([alignRight intValue] == 1) {
                    stringFromTableTextPrevious = [[[stringFromTableTextPrevious stringByAppendingFormat:@"\u202B%@ ", tblVerseNrStr] stringByAppendingString:tblTextStr] stringByAppendingString:@"\r\n"];
                }
                else {
                    stringFromTableTextPrevious = [[[[stringFromTableTextPrevious stringByAppendingString:tblVerseNrStr] stringByAppendingString:@" "] stringByAppendingString:tblTextStr] stringByAppendingString:@"\r\n"];
                }
                [tblVerseNrStr release];
                [tblTextStr release];
            }
            
            if ((stringFromTableTextPrevious == @"") || (stringFromTableTextPrevious == nil)) {
                //                [self alignText:@"left"];
                NSString *otherSection = @"";
                if ((bookCurrentNumber <= 66) && (bookCurrentNumber >= 40)) {
                    otherSection = @"New Testament";
                }
                else if ((bookCurrentNumber >= 1) && (bookCurrentNumber <= 39)) {
                    otherSection = @"Tanakh";
                }
                stringFromTableTextPrevious = [NSString stringWithFormat:@"Text not available in current translation. Please browse to %@ or load another language.", otherSection];
            }
            //---deletes the compiled statement from memory---
            sqlite3_finalize(statement);
        }
        [[NSUserDefaults standardUserDefaults]setObject:stringFromTableTextPrevious forKey:@"stringFromTableTextPrevious"];
    }
}

- (void) getTextFromTable: (NSString *) turnPage {
    NSLog(@"Start getTextFromTable");
    textView1.font = [UIFont fontWithName:fontName size:fontSize];
    
    if (turnPage == @"forward") {
        NSLog(@"FORWARD");
        stringFromTableTextNext = [[NSUserDefaults standardUserDefaults]objectForKey:@"stringFromTableTextNext"];
        stringFromTableText = stringFromTableTextNext;
        [self updateView];
        
        [self loadOtherPage:@"next"];
        [self loadOtherPage:@"previous"];
    }
    else if (turnPage == @"backward") {
        NSLog(@"BACKWARD");
        stringFromTableTextPrevious = [[NSUserDefaults standardUserDefaults]objectForKey:@"stringFromTableTextPrevious"];
        stringFromTableText = stringFromTableTextPrevious;
        [self updateView];
        
        [self loadOtherPage:@"next"];
        [self loadOtherPage:@"previous"];
    }
    else if (turnPage == @"same") {
        NSLog(@"SAME");
        if (!stringFromTableText) {
            //---initialise stringFromTableText---
            stringFromTableText = @"";
            //---Get the location to load, from the config file.---
            NSString *location = [[self getLocation] objectAtIndex:1];
            NSArray *piecesArray = [location componentsSeparatedByString:@"\t"];
            bookCurrentNumber = [[piecesArray objectAtIndex:0] intValue];
            chapterCurrentNumber = [[piecesArray objectAtIndex:1] intValue];
            verseCurrentNumber = [[piecesArray objectAtIndex:2] intValue];
            
            if (!chapterSelectedNumber) {
                if (!chapterCurrentNumber) {
                    chapterCurrentNumber = 1;
                }
                chapterSelectedNumber = chapterCurrentNumber;
            }
            if (!verseSelectedNumber) {
                if (!verseCurrentNumber) {
                    verseCurrentNumber = 1;
                }
                verseSelectedNumber = verseCurrentNumber;
            }
            
            NSInteger tempBookNumber = [self bookOrder:bookCurrentNumber];
            
            //---retrieve rows---
            NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND chapterNr = %d", tableName, tempBookNumber, chapterCurrentNumber];
            NSLog(@"QSQL: %@", qsql);
            
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    //---verse number
                    char *tblVerseNrChr = (char *) sqlite3_column_text(statement, 4);
                    NSString *tblVerseNrStr = [[NSString alloc] initWithUTF8String:tblVerseNrChr];
                    
                    //---text
                    char *tblTextChr = (char *) sqlite3_column_text(statement, 5);
                    NSString *tblTextStr = [[NSString alloc] initWithUTF8String:tblTextChr];
                    
                    if ([alignRight intValue] == 1) {
                        stringFromTableText = [[[stringFromTableText stringByAppendingFormat:@"\u202B%@ ", tblVerseNrStr] stringByAppendingString:tblTextStr] stringByAppendingString:@"\r\n"];
                    }
                    else {
                        stringFromTableText = [[[[stringFromTableText stringByAppendingString:tblVerseNrStr] stringByAppendingString:@" "] stringByAppendingString:tblTextStr] stringByAppendingString:@"\r\n"];
                    }
                    [tblVerseNrStr release];
                    [tblTextStr release];
                }
                
                if ((stringFromTableText == @"") || (stringFromTableText == nil)) {
                    [self alignText:@"left"];
                    NSString *otherSection = @"";
                    if ((bookCurrentNumber <= 66) && (bookCurrentNumber >= 40)) {
                        otherSection = @"New Testament";
                    }
                    else if ((bookCurrentNumber >= 1) && (bookCurrentNumber <= 39)) {
                        otherSection = @"Tanakh";
                    }
                    stringFromTableText = [NSString stringWithFormat:@"Text not available in current translation. Please browse to %@ or load another language.", otherSection];
                }
                //---deletes the compiled statement from memory---
                sqlite3_finalize(statement);
                
                [self updateView];
            }
            else {
                NSLog(@"Help! I can't access the database!!!");
            }
            
            //---load the previous page---
            [self loadOtherPage:@"previous"];
            
            //---load the next page---
            [self loadOtherPage:@"next"];
        }
        else {
            //---initialise stringFromTableText---
            stringFromTableText = @"";
            //---Get the location to load, from the config file.---
            NSString *location = [[self getLocation] objectAtIndex:1];
            NSArray *piecesArray = [location componentsSeparatedByString:@"\t"];
            bookCurrentNumber = [[piecesArray objectAtIndex:0] intValue];
            chapterCurrentNumber = [[piecesArray objectAtIndex:1] intValue];
            verseCurrentNumber = [[piecesArray objectAtIndex:2] intValue];
            
            if (!chapterSelectedNumber) {
                if (!chapterCurrentNumber) {
                    chapterCurrentNumber = 1;
                }
                chapterSelectedNumber = chapterCurrentNumber;
            }
            if (!verseSelectedNumber) {
                if (!verseCurrentNumber) {
                    verseCurrentNumber = 1;
                }
                verseSelectedNumber = verseCurrentNumber;
            }
            
            NSInteger tempBookNumber = [self bookOrder:bookCurrentNumber];
            
            //---retrieve rows---
            NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND chapterNr = %d", tableName, tempBookNumber, chapterCurrentNumber];
            NSLog(@"QSQL: %@", qsql);
            
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    //---verse number
                    char *tblVerseNrChr = (char *) sqlite3_column_text(statement, 4);
                    NSString *tblVerseNrStr = [[NSString alloc] initWithUTF8String:tblVerseNrChr];
                    
                    //---text
                    char *tblTextChr = (char *) sqlite3_column_text(statement, 5);
                    NSString *tblTextStr = [[NSString alloc] initWithUTF8String:tblTextChr];
                    
                    if ([alignRight intValue] == 1) {
                        stringFromTableText = [[[stringFromTableText stringByAppendingFormat:@"\u202B%@ ", tblVerseNrStr] stringByAppendingString:tblTextStr] stringByAppendingString:@"\r\n"];
                    }
                    else {
                        stringFromTableText = [[[[stringFromTableText stringByAppendingString:tblVerseNrStr] stringByAppendingString:@" "] stringByAppendingString:tblTextStr] stringByAppendingString:@"\r\n"];
                    }
                    [tblVerseNrStr release];
                    [tblTextStr release];
                }
                
                if ((stringFromTableText == @"") || (stringFromTableText == nil)) {
                    [self alignText:@"left"];
                    NSString *otherSection = @"";
                    if ((bookCurrentNumber <= 66) && (bookCurrentNumber >= 40)) {
                        otherSection = @"New Testament";
                    }
                    else if ((bookCurrentNumber >= 1) && (bookCurrentNumber <= 39)) {
                        otherSection = @"Tanakh";
                    }
                    stringFromTableText = [NSString stringWithFormat:@"Text not available in current translation. Please browse to %@ or load another language.", otherSection];
                }
                //---deletes the compiled statement from memory---
                sqlite3_finalize(statement);
                
                [self updateView];
            }
            
            //---load the previous page---
            [self loadOtherPage:@"previous"];
            
            //---load the next page---
            [self loadOtherPage:@"next"];
        }
    }
    NSLog(@"End getTextFromTable");
}

- (void) writeConfigToFile: (NSMutableDictionary *) copyOfDict {
    [generalModel writeConfigToFile:copyOfDict];
}

- (NSMutableArray *) checkLocationValidity: (NSMutableArray *) locationArray: (NSString *) turnPage {
    return [generalModel checkLocationValidity:locationArray :turnPage];
}

- (void) setLocation:(NSMutableArray *) locationArray:(NSString *) turnPage {
    [generalModel setLocation:locationArray :turnPage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    generalModel = [[GeneralModel alloc] init];
    if (_biblePicked) {
        NSLog(@"BIBLEPICKED: %@", _biblePicked);
        //---get the path to the property list file---
        NSString *localPlistFileNameConf = [[generalModel documentsPath] stringByAppendingPathComponent:@"Config.plist"];
        NSMutableDictionary *copyOfDict;
        //---if the property list file can be found---
        if ([[NSFileManager defaultManager] fileExistsAtPath:localPlistFileNameConf]) {
            //---load the content of the property list file into a NSDictionary object---
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:localPlistFileNameConf];
            //---make a mutable copy of the dictionary object---
            copyOfDict = [dict mutableCopy];
            
            if (_biblePicked == @"עִבְרִית תַּנַייךְ") {
                [copyOfDict setValue:@"עִבְרִית תַּנַייךְ" forKey:@"Choice"];
                [copyOfDict setValue:@"OT" forKey:@"PartFlag"];
                partFlag = @"OT";
            }
            else if (_biblePicked == @"ייִדיש תנך") {                    [copyOfDict setValue:@"ייִדיש תנך" forKey:@"Choice"];
                [copyOfDict setValue:@"OT" forKey:@"PartFlag"];
                partFlag = @"OT";
            }
            else if (_biblePicked == @"עִבְרִית הברית החדשה") {
                [copyOfDict setValue:@"עִבְרִית הברית החדשה" forKey:@"Choice"];
                [copyOfDict setValue:@"NT" forKey:@"PartFlag"];
                partFlag = @"NT";
            }
            else if (_biblePicked == @"English") {
                [copyOfDict setValue:@"English" forKey:@"Choice"];
                [copyOfDict setValue:@"FULL" forKey:@"PartFlag"];
                partFlag = @"FULL";
            }
            
            [self writeConfigToFile:copyOfDict];
            [dict release];
            [copyOfDict release];
        }
        else {
            //---load the property list from the Resources folder---
            NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:pListPath];
            //---make a mutable copy of the dictionary object---
            copyOfDict = [dict mutableCopy];
            
            if (_biblePicked == @"עִבְרִית תַּנַייךְ") {
                [copyOfDict setValue:@"עִבְרִית תַּנַייךְ" forKey:@"Choice"];
                [copyOfDict setValue:@"OT" forKey:@"PartFlag"];
                partFlag = @"OT";
            }
            else if (_biblePicked == @"ייִדיש תנך") {                    [copyOfDict setValue:@"ייִדיש תנך" forKey:@"Choice"];
                [copyOfDict setValue:@"OT" forKey:@"PartFlag"];
                partFlag = @"OT";
            }
            else if (_biblePicked == @"עִבְרִית הברית החדשה") {
                [copyOfDict setValue:@"עִבְרִית הברית החדשה" forKey:@"Choice"];
                [copyOfDict setValue:@"NT" forKey:@"PartFlag"];
                partFlag = @"NT";
            }
            else if (_biblePicked == @"English") {
                [copyOfDict setValue:@"English" forKey:@"Choice"];
                [copyOfDict setValue:@"FULL" forKey:@"PartFlag"];
                partFlag = @"FULL";
            }
            
            [self writeConfigToFile:copyOfDict];
            [dict release];
            [copyOfDict release];
        }
    }
    [self openDB];
    [self getProperties];
    plzChangeFontSize = FALSE;
    [self getTextFromTable:@"same"];
    
    //---right swipe (default)---
	UISwipeGestureRecognizer *swipeRightGesture1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
	[self.view addGestureRecognizer:swipeRightGesture1];
	[swipeRightGesture1 release];
    
	//---left swipe---
	UISwipeGestureRecognizer *swipeLeftGesture1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
	swipeLeftGesture1.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:swipeLeftGesture1];
	[swipeLeftGesture1 release];
    NSLog(@"End viewDidLoad");
}

//---handle swipe gesture---
-(IBAction) handleSwipeGesture: (UIGestureRecognizer *) sender {
    NSLog(@"Start handleSwipeGesture");
	UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
    //---initialize the first textview to display text---
	switch (direction) {
		case UISwipeGestureRecognizerDirectionLeft: {
            //---Extract values from location string and increase the appropriate ones then store it into the config file again---
            //---Get the location to load, from the config file.---
            NSString *location = [[self getLocation] objectAtIndex:1];
            NSLog(@"===> Location from PLIST: %@", location);
            NSArray *piecesArray = [location componentsSeparatedByString:@"\t"];
            bookCurrentNumber = [[piecesArray objectAtIndex:0] intValue];
            chapterCurrentNumber = [[piecesArray objectAtIndex:1] intValue];
            verseCurrentNumber = [[piecesArray objectAtIndex:2] intValue];
            
            if (!chapterSelectedNumber) {
                if (!chapterCurrentNumber) {
                    chapterCurrentNumber = 1;
                }
                chapterSelectedNumber = chapterCurrentNumber;
            }
            if (!verseSelectedNumber) {
                if (!verseCurrentNumber) {
                    verseCurrentNumber = 1;
                }
                verseSelectedNumber = verseCurrentNumber;
            }
            
            //---prepare the location and then store it---
            NSString *locationNewCurrent, *locationNewPrevious, *locationNewNext, *locationNewPreAmble;
            
            locationNewPreAmble = [NSString stringWithFormat:@"%02d", (bookCurrentNumber)];
            if (((bookCurrentNumber) <= 39) && ((bookCurrentNumber) >= 1)) {
                locationNewPreAmble = [locationNewPreAmble stringByAppendingString:@"Otabkey"];
            }
            else {
                if (((bookCurrentNumber) >= 40) && ((bookCurrentNumber) <= 66)) {
                    locationNewPreAmble = [locationNewPreAmble stringByAppendingString:@"Ntabkey"];
                }
            }
            locationNewCurrent = [[locationNewPreAmble stringByAppendingFormat:@"%dtabkey", chapterCurrentNumber] stringByAppendingFormat:@"%d", verseCurrentNumber];
            locationNewPrevious = [[locationNewPreAmble stringByAppendingFormat:@"%dtabkey", chapterCurrentNumber - 1] stringByAppendingFormat:@"%d", verseCurrentNumber];
            locationNewNext = [[locationNewPreAmble stringByAppendingFormat:@"%dtabkey", chapterCurrentNumber + 1] stringByAppendingFormat:@"%d", verseCurrentNumber];
            NSMutableArray *locationNewArray = [NSMutableArray arrayWithObjects:locationNewPrevious, locationNewCurrent, locationNewNext, nil];

            [self getProperties];
			[self setLocation:locationNewArray:@"forward"];
            
            [self getTextFromTable:@"forward"];
			
			[UIView beginAnimations:@"flipping view" context:nil];
			[UIView setAnimationDuration:0.4];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
			[UIView commitAnimations];
			break;
		}
		case UISwipeGestureRecognizerDirectionRight: {
            //---Extract values from location string and increase the appropriate ones then store it into the config file again---
            //---Get the location to load, from the config file.---
            NSString *location = [[self getLocation] objectAtIndex:1];
            NSArray *piecesArray = [location componentsSeparatedByString:@"\t"];
            bookCurrentNumber = [[piecesArray objectAtIndex:0] intValue];
            chapterCurrentNumber = [[piecesArray objectAtIndex:1] intValue];
            verseCurrentNumber = [[piecesArray objectAtIndex:2] intValue];
            
            if (!chapterSelectedNumber) {
                if (!chapterCurrentNumber) {
                    chapterCurrentNumber = 1;
                }
                chapterSelectedNumber = chapterCurrentNumber;
            }
            if (!verseSelectedNumber) {
                if (!verseCurrentNumber) {
                    verseCurrentNumber = 1;
                }
                verseSelectedNumber = verseCurrentNumber;
            }
            
			//---prepare the location and then store it---
            NSString *locationNewCurrent, *locationNewPrevious, *locationNewNext, *locationNewPreAmble;
            
            locationNewPreAmble = [NSString stringWithFormat:@"%02d", (bookCurrentNumber)];
            if (((bookCurrentNumber) <= 39) && ((bookCurrentNumber) >= 1)) {
                locationNewPreAmble = [locationNewPreAmble stringByAppendingString:@"Otabkey"];
            }
            else {
                if (((bookCurrentNumber) >= 40) && ((bookCurrentNumber) <= 66)) {
                    locationNewPreAmble = [locationNewPreAmble stringByAppendingString:@"Ntabkey"];
                }
            }
            
            locationNewCurrent = [[locationNewPreAmble stringByAppendingFormat:@"%dtabkey", chapterCurrentNumber] stringByAppendingFormat:@"%d", verseCurrentNumber];
            locationNewPrevious = [[locationNewPreAmble stringByAppendingFormat:@"%dtabkey", chapterCurrentNumber - 1] stringByAppendingFormat:@"%d", verseCurrentNumber];
            locationNewNext = [[locationNewPreAmble stringByAppendingFormat:@"%dtabkey", chapterCurrentNumber + 1] stringByAppendingFormat:@"%d", verseCurrentNumber];
            NSMutableArray *locationNewArray = [NSMutableArray arrayWithObjects:locationNewPrevious, locationNewCurrent, locationNewNext, nil];
            
            [self getProperties];
            [self setLocation:locationNewArray:@"backward"];
            
            [self getTextFromTable:@"backward"];
			
			[UIView beginAnimations:@"flipping view" context:nil];
			[UIView setAnimationDuration:0.4];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
			[UIView commitAnimations];
			break;
		}
		default:
			break;
	}
    NSLog(@"End handleSwipeGesture");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)lefty:(UISwipeGestureRecognizer *)sender {
}
- (void)dealloc {
    [generalModel release];
    [textView1 release];
    [lblLocation release];
    sqlite3_close(db);
    [super dealloc];
}
@end
