//
//  GeneralModel.m
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 12/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import "GeneralModel.h"

@implementation GeneralModel

NSString *partFlag;
NSInteger bookCurrentNumber, chapterCurrentNumber, verseCurrentNumber;
bool bookOrderJewish;
NSMutableArray *bnames;
NSMutableDictionary *BookmarksPlist;

//---finds the path to the application's Documents directory---
- (NSString *) documentsPath {
    //    NSLog(@"~~~ documentsPath");
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return documentsDir;
}

- (NSString *) configPath {
    //    NSLog(@"~~~ configPath");
    NSString *plistFileNameConf = [[self documentsPath] stringByAppendingPathComponent:@"Config.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistFileNameConf]) {
        plistFileNameConf = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    }
    return plistFileNameConf;
}

- (NSString *) filePath {
    //    NSLog(@"~~~ filePath");
    return [[self documentsPath] stringByAppendingPathComponent:@"sdhs_bible.sql"];
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
    NSLog(@"Do bookOrder for bookNr:%d", bookToCheck);
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:[self configPath]];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    
    bookOrderJewish = [temp objectForKey:@"BookOrderJewish"];
    
    if (bookOrderJewish) {
        //---Load the Jewish equivalent---
        NSArray *jewishBookNumberArray = [NSArray arrayWithObjects:
                                          [NSNumber numberWithInteger:0],
                                          [NSNumber numberWithInteger:1],
                                          [NSNumber numberWithInteger:2],
                                          [NSNumber numberWithInteger:3],
                                          [NSNumber numberWithInteger:4],
                                          [NSNumber numberWithInteger:5],
                                          [NSNumber numberWithInteger:6],
                                          [NSNumber numberWithInteger:7],
                                          [NSNumber numberWithInteger:9],
                                          [NSNumber numberWithInteger:10],
                                          [NSNumber numberWithInteger:11],
                                          [NSNumber numberWithInteger:12],
                                          [NSNumber numberWithInteger:23],
                                          [NSNumber numberWithInteger:24],
                                          [NSNumber numberWithInteger:26],
                                          [NSNumber numberWithInteger:28],
                                          [NSNumber numberWithInteger:29],
                                          [NSNumber numberWithInteger:30],
                                          [NSNumber numberWithInteger:31],
                                          [NSNumber numberWithInteger:32],
                                          [NSNumber numberWithInteger:33],
                                          [NSNumber numberWithInteger:34],
                                          [NSNumber numberWithInteger:35],
                                          [NSNumber numberWithInteger:36],
                                          [NSNumber numberWithInteger:37],
                                          [NSNumber numberWithInteger:38],
                                          [NSNumber numberWithInteger:39],
                                          [NSNumber numberWithInteger:19],
                                          [NSNumber numberWithInteger:20],
                                          [NSNumber numberWithInteger:18],
                                          [NSNumber numberWithInteger:22],
                                          [NSNumber numberWithInteger:8],
                                          [NSNumber numberWithInteger:25],
                                          [NSNumber numberWithInteger:21],
                                          [NSNumber numberWithInteger:17],
                                          [NSNumber numberWithInteger:27],
                                          [NSNumber numberWithInteger:15],
                                          [NSNumber numberWithInteger:16],
                                          [NSNumber numberWithInteger:13],
                                          [NSNumber numberWithInteger:14],
                                          nil];
        if ((bookToCheck <= 39) && (bookToCheck >= 1)) {
            bookToCheck = [[jewishBookNumberArray objectAtIndex:bookToCheck] intValue];
        }
    }
    return bookToCheck;
}

- (NSString *)loadBookname: (NSInteger) bookToLoad {
    NSLog(@"Start loadBookname");
    //    bookToLoad = [self bookOrder:bookToLoad];
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:[self configPath]];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    
    bnames = [temp objectForKey:@"BookNames"];
    
    NSString *bookNameTemp;
    bookNameTemp = [bnames objectAtIndex:bookToLoad - 1];
    NSLog(@"End loadBookname");
    return bookNameTemp;
}

- (NSArray *) getProperties {
    NSLog(@"Start getProperties");
    NSString *Choice;
    NSArray *allProperties, *properties, *BookmarksPlistText;
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:[self configPath]];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    BookmarksPlist = [temp objectForKey:@"Bookmarks"];
    BookmarksPlistText = [[temp objectForKey:@"Bookmarks"] allValues];
    partFlag = [temp objectForKey:@"PartFlag"];
    Choice = [temp objectForKey:@"Choice"];
    properties = [temp objectForKey:Choice];
	
	tableName = [properties objectAtIndex:0];
	alignRight = [properties objectAtIndex:1];
    
	fontName = [properties objectAtIndex:2];
	fontSizeStr = [properties objectAtIndex:3];
    allProperties = [NSArray arrayWithObjects:partFlag, tableName, alignRight, fontName, fontSizeStr, Choice, BookmarksPlist, BookmarksPlistText, nil];
    NSLog(@"End getProperties");
    return allProperties;
}

- (void) writeConfigToFile: (NSMutableDictionary *) copyOfDict {
	NSLog(@"Start writeConfigToFile");
    //---write the dictionary to file---
	NSString *configFile = [[self documentsPath] stringByAppendingPathComponent:@"Config.plist"];
	
	[copyOfDict writeToFile:configFile atomically:YES];
    //	[copyOfDict release];
    NSLog(@"End writeConfigToFile");
}

- (NSMutableArray *) checkLocationValidity: (NSMutableArray *) locationArray: (NSString *) turnPage {
    NSLog(@"Start checkLocationValidity");
    //  turnPage can be set to either
    //  forward
    //  backward
    //  same - default
    
    [self openDB];
    
    NSArray *piecesArray = [[locationArray objectAtIndex:1] componentsSeparatedByString:@"tabkey"];
    bookCurrentNumber = [[piecesArray objectAtIndex:0] intValue];
    chapterCurrentNumber = [[piecesArray objectAtIndex:1] intValue];
    verseCurrentNumber = [[piecesArray objectAtIndex:2] intValue];
    
    NSInteger chapterCount = 0;
    NSInteger tempBookNumber = [self bookOrder:bookCurrentNumber];
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"bookCurrentNumber"] intValue] != bookCurrentNumber) {
        //---Check current chapter against chapter count then decide whether to just increase the chapter or to increase the book number as well---
        //---retrieve rows---
        
        NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND verseNr = 1", tableName, tempBookNumber];
        NSLog(@"qSqL: %@", qsql);
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                chapterCount++;
            }
        }
        else {
            NSLog(@"HELP ME! I can't read this database! GenMod checkLocationValidity");
        }
        //---deletes the compiled statement from memory---
        sqlite3_finalize(statement);
        
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d", chapterCount] forKey:@"chapterCount"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d", bookCurrentNumber] forKey:@"bookCurrentNumber"];
    }
    else {
        chapterCount = [[[NSUserDefaults standardUserDefaults]objectForKey:@"chapterCount"] intValue];
    }
    
    if (chapterCurrentNumber < 1) {
        chapterCurrentNumber = 1;
    }
    
    if (turnPage == @"forward") {
        if (chapterCurrentNumber < chapterCount) {
            chapterCurrentNumber++;
        }
        else if (bookCurrentNumber < 66) {
            bookCurrentNumber++;
            chapterCurrentNumber = 1;
        }
    }
    else if (turnPage == @"backward") {
        if (chapterCurrentNumber > 1) {
            chapterCurrentNumber--;
        }
        else if (bookCurrentNumber > 1) {
            bookCurrentNumber--;
            
            tempBookNumber = [self bookOrder:bookCurrentNumber];
            
            //---retrieve rows to find last chapter of previous book---
            NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND verseNr = 1", tableName, tempBookNumber];
            NSLog(@"qSqL: %@", qsql);
            chapterCount = 0;
            
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    chapterCount++;
                }
            }
            
            //---deletes the compiled statement from memory---
            sqlite3_finalize(statement);
            
            chapterCurrentNumber = chapterCount;
        }
    }
    else {
    }
    
    NSInteger chapterNext = 1;
    NSInteger chapterPrevious = 1;
    NSInteger bookNext = bookCurrentNumber;
    NSInteger bookPrevious = bookCurrentNumber;
    
    if (turnPage == @"forward") {
        //---Now check the next page location for validity
        if (chapterCurrentNumber < chapterCount) {
            chapterNext = chapterCurrentNumber + 1;
        }
        else if ((chapterCurrentNumber > 0) && (bookNext <= 66)) {
            chapterNext = 1;
            bookNext++;
        }
        else {
            chapterNext = chapterCurrentNumber;
        }
        
        //---Now set the old page location as the previous page
        if (chapterCurrentNumber > 1) {
//            if (bookCurrentNumber > 1) {
                chapterPrevious = chapterCurrentNumber - 1;
//            }
//            else {
//                chapterPrevious = 1;
//            }
        }
        else {
            if (bookCurrentNumber > 1) {
                bookPrevious--;
                tempBookNumber = [self bookOrder:bookPrevious];
                NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND verseNr = 1", tableName, tempBookNumber];
                NSLog(@"qSqL: %@", qsql);
                NSInteger tempChapterCount = 0;
                
                sqlite3_stmt *statement;
                if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
                    while (sqlite3_step(statement) == SQLITE_ROW) {
                        tempChapterCount++;
                    }
                }
                
                //---deletes the compiled statement from memory---
                sqlite3_finalize(statement);
                
                chapterPrevious = tempChapterCount;
            }
            else {
                chapterPrevious = 1;
            }
        }
    }
    else if (turnPage == @"backward") {
        //---Now check the previous page for validity
        if (chapterCurrentNumber > 1) {
            chapterPrevious = chapterCurrentNumber - 1;
        }
        else if (bookPrevious > 1) {
            bookPrevious--;
            tempBookNumber = [self bookOrder:bookPrevious];
            NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND verseNr = 1", tableName, tempBookNumber];
            NSLog(@"qSqL: %@", qsql);
            NSInteger tempChapterCount = 0;
            
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    tempChapterCount++;
                }
            }
            
            //---deletes the compiled statement from memory---
            sqlite3_finalize(statement);
            
            chapterPrevious = tempChapterCount;
        }
        else {
            chapterPrevious = chapterCurrentNumber;
        }
        
        //---Now set the old page loaction as the next page
        if (chapterCurrentNumber < chapterCount) {
            chapterNext = chapterCurrentNumber + 1;
        }
        else {
            chapterNext = 1;
            bookNext++;
        }
    }
    else {
        //---Now check the previous page for validity
        if (chapterCurrentNumber > 1) {
            chapterPrevious = chapterCurrentNumber - 1;
        }
        else if (bookCurrentNumber > 1) {
            bookPrevious--;
            tempBookNumber = [self bookOrder:bookPrevious];
            NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookNr = %d AND verseNr = 1", tableName, tempBookNumber];
            NSLog(@"qSqL: %@", qsql);
            NSInteger tempChapterCount = 0;
            
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    tempChapterCount++;
                }
            }
            
            //---deletes the compiled statement from memory---
            sqlite3_finalize(statement);
            
            chapterPrevious = tempChapterCount;
        }
        else {
            chapterPrevious = chapterCurrentNumber;
        }
        
        //---Now check the next page for validity
        if (chapterCurrentNumber < chapterCount) {
            chapterNext = chapterCurrentNumber + 1;
        }
        else if (partFlag == @"OT") {
            if (bookCurrentNumber < 39) {
                chapterNext = 1;
                bookNext++;
            }
        }
        else if (bookCurrentNumber < 66) {
            chapterNext = 1;
            bookNext++;
        }
        else {
            chapterNext = chapterCurrentNumber;
        }
    }
    
    NSString *locationTemp;
    locationTemp = [NSString stringWithFormat:@"%02d", bookCurrentNumber];
    if ((bookCurrentNumber <= 39) && (bookCurrentNumber >= 1)) {
        locationTemp = [locationTemp stringByAppendingString:@"Otabkey"];
    }
    else if ((bookCurrentNumber >= 40) && (bookCurrentNumber <= 66)) {
        locationTemp = [locationTemp stringByAppendingString:@"Ntabkey"];
    }
    locationTemp = [[locationTemp stringByAppendingFormat:@"%dtabkey", chapterCurrentNumber] stringByAppendingFormat:@"%d", verseCurrentNumber];
    [locationArray replaceObjectAtIndex:1 withObject:locationTemp];
    
    locationTemp = [NSString stringWithFormat:@"%02d", bookPrevious];
    if ((bookPrevious <= 39) && (bookPrevious <= 66)) {
        locationTemp = [locationTemp stringByAppendingString:@"Otabkey"];
    }
    else if ((bookPrevious >= 40) && (bookPrevious <= 66)) {
        locationTemp = [locationTemp stringByAppendingString:@"Ntabkey"];
    }
    locationTemp = [[locationTemp stringByAppendingFormat:@"%dtabkey", chapterPrevious] stringByAppendingFormat:@"%d", verseCurrentNumber];
    [locationArray replaceObjectAtIndex:0 withObject:locationTemp];
    
    locationTemp = [NSString stringWithFormat:@"%02d", bookNext];
    if ((bookNext <= 39) && (bookNext <= 66)) {
        locationTemp = [locationTemp stringByAppendingString:@"Otabkey"];
    }
    else if ((bookNext >= 40) && (bookNext <= 66)) {
        locationTemp = [locationTemp stringByAppendingString:@"Ntabkey"];
    }
    locationTemp = [[locationTemp stringByAppendingFormat:@"%dtabkey", chapterNext] stringByAppendingFormat:@"%d", verseCurrentNumber];
    [locationArray replaceObjectAtIndex:2 withObject:locationTemp];
    
    sqlite3_close(db);
    NSLog(@"End checkLocationValidity");
    return locationArray;
}

- (NSMutableArray *) getLocation {
    NSLog(@"Start getLocation");
    NSString *locationPrevious, *locationCurrent, *locationNext;
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:[self configPath]];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    locationPrevious = [temp objectForKey:@"LocationPrevious"];
    locationPrevious = [locationPrevious stringByReplacingOccurrencesOfString:@"tabkey" withString:@"\t"];
    
    locationCurrent = [temp objectForKey:@"Location"];
	locationCurrent = [locationCurrent stringByReplacingOccurrencesOfString:@"tabkey" withString:@"\t"];
    
    locationNext = [temp objectForKey:@"LocationNext"];
    locationNext = [locationNext stringByReplacingOccurrencesOfString:@"tabkey" withString:@"\t"];
    
    NSMutableArray *locationArray = [NSMutableArray arrayWithObjects:locationPrevious, locationCurrent, locationNext, nil];
    
	NSLog(@"End getLocation");
	return locationArray;
}

- (void) setLocation:(NSMutableArray *) locationArray:(NSString *) turnPage {
    NSLog(@"Start setLocation");
	//---get the path to the property list file---
	NSString *localPlistFileNameConf = [[self documentsPath] stringByAppendingPathComponent:@"Config.plist"];
    NSMutableDictionary *copyOfDict;
	//---if the property list file can be found---
	if ([[NSFileManager defaultManager] fileExistsAtPath:localPlistFileNameConf]) {
		//---load the content of the property list file into a NSDictionary object---
		NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:localPlistFileNameConf];
        //---make a mutable copy of the dictionary object---
        copyOfDict = [dict mutableCopy];
        
        locationArray = [self checkLocationValidity:locationArray:turnPage];
        [copyOfDict setValue:[locationArray objectAtIndex:0] forKey:@"LocationPrevious"];
        [copyOfDict setValue:[locationArray objectAtIndex:1] forKey:@"Location"];
        [copyOfDict setValue:[locationArray objectAtIndex:2] forKey:@"LocationNext"];
        
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
        
        locationArray = [self checkLocationValidity:locationArray:turnPage];
        [copyOfDict setValue:[locationArray objectAtIndex:0] forKey:@"LocationPrevious"];
        [copyOfDict setValue:[locationArray objectAtIndex:1] forKey:@"Location"];
        [copyOfDict setValue:[locationArray objectAtIndex:2] forKey:@"LocationNext"];
        
        [self writeConfigToFile:copyOfDict];
        [dict release];
        [copyOfDict release];
	}
    
    NSLog(@"End setLocation");
}

@end
