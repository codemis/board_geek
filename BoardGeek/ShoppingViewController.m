//
//  ShoppingViewController.m
//  BoardGeek
//
//  Created by Johnathan Pulos on 10/6/12.
//  Copyright (c) 2012 Johnathan Pulos. All rights reserved.
//

#import "ShoppingViewController.h"

@interface ShoppingViewController ()

@end

@implementation ShoppingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.gameName);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

@end
