//
//  DetailsViewController.m
//  BoardGeek
//
//  Created by Johnathan Pulos on 9/14/12.
//  Copyright (c) 2012 Johnathan Pulos. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", self.gameId);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = cell.reuseIdentifier;
    // Configure the cell...
    if ([identifier isEqualToString:@"name"]) {
        cell.textLabel.text = @"My Game Name";
    }else if ([identifier isEqualToString:@"publishedOn"]) {
        cell.textLabel.text = @"Today";
    }else if ([identifier isEqualToString:@"numPlayers"]) {
        cell.textLabel.text = @"2-10";
    }else if ([identifier isEqualToString:@"duration"]) {
        cell.textLabel.text = @"2 Hours";
    }else if ([identifier isEqualToString:@"categories"]) {
        cell.textLabel.text = @"French, German, Italian";
    }else if ([identifier isEqualToString:@"description"]) {
        cell.textLabel.text = @"A really great game";
    }
    return cell;
}

@end
