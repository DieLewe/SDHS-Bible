//
//  BookmarkTableViewCell.m
//  SDHS Bible V2
//
//  Created by Rohan Meyer on 26/11/2012.
//  Copyright (c) 2012 The Society for Distributing Hebrew Scriptures. All rights reserved.
//

#import "BookmarkTableViewCell.h"

@implementation BookmarkTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_lblBookmark release];
    [super dealloc];
}
@end
