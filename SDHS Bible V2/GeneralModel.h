//
//  GeneralModel.h
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 12/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface GeneralModel : NSObject {
    sqlite3 *db;
    NSString *tableName, *alignRight, *fontName, *fontSizeStr;
    NSInteger fontSizeInt;
}
-(NSString *) documentsPath;
-(NSString *) configPath;
-(NSString *) filePath;
-(void) openDB;
-(NSInteger) bookOrder: (NSInteger) bookToCheck;
-(NSString *)loadBookname: (NSInteger) bookToLoad;
-(NSArray *) getProperties;
-(void) writeConfigToFile: (NSMutableDictionary *) copyOfDict;
-(NSMutableArray *) checkLocationValidity: (NSMutableArray *) locationArray: (NSString *) turnPage;
-(NSMutableArray *) getLocation;
-(void) setLocation:(NSMutableArray *) locationArray:(NSString *) turnPage;
@end
