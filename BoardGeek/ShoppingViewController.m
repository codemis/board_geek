//
//  ShoppingViewController.m
//  BoardGeek
//
//  Created by Johnathan Pulos on 10/6/12.
//  Copyright (c) 2012 Johnathan Pulos. All rights reserved.
//

#import "ShoppingViewController.h"

@interface ShoppingViewController ()<NSXMLParserDelegate>
@property NSMutableArray *shoppingResults;
@property NSMutableDictionary *shoppingItem;
@property NSMutableString *innerContent;
@property NSDictionary *settings;
@end

@implementation ShoppingViewController

-(void)grabXMLData {
    NSString *apiKey = [self.settings objectForKey:@"GoogleApiKey"];
    NSString *shoppingUrl = [NSString stringWithFormat:@"https://www.googleapis.com/shopping/search/v1/public/products?key=%@&country=US&q=%@&alt=atom", apiKey, self.gameName];
    NSURL *url = [[NSURL alloc] initWithString:shoppingUrl];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [xmlParser setDelegate:self];
    BOOL success = [xmlParser parse];
    if (success) {
        NSLog(@"%@", self.shoppingResults);
        [self.tableView reloadData];
    } else{
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shoppingResults = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"appSettings" ofType:@"plist"];
    self.settings = [[NSDictionary alloc] initWithContentsOfFile:path];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // Delay XML Parse so the indicators get set.  Parsing is synchronise, and will block indicators
    [self performSelector:@selector(grabXMLData) withObject:nil afterDelay:0.5];
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

#pragma mark
#pragma NSXMLParser Delegates

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"entry"]) {
        self.shoppingItem = [[NSMutableDictionary alloc] init];
    }
    self.innerContent = [[NSMutableString alloc] init];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSMutableString *content = [NSMutableString stringWithString:string];
    [self.innerContent appendString:content];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"name"]) {
        //Strip white spaces
        //http://stackoverflow.com/questions/3200521/cocoa-trim-all-leading-whitespace-from-nsstring
        NSRange range = [self.innerContent rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        NSString *name = [self.innerContent stringByReplacingCharactersInRange:range withString:@""];
        [self.shoppingItem setObject:name forKey:@"seller"];
        self.innerContent = nil;
    }
    if ([elementName isEqualToString:@"title"]) {
        //Strip white spaces
        NSRange range = [self.innerContent rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        NSString *title = [self.innerContent stringByReplacingCharactersInRange:range withString:@""];
        [self.shoppingItem setObject:title forKey:@"title"];
        self.innerContent = nil;
    }
    if ([elementName isEqualToString:@"s:link"]) {
        //Strip white spaces
        NSRange range = [self.innerContent rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        NSString *link = [self.innerContent stringByReplacingCharactersInRange:range withString:@""];
        [self.shoppingItem setObject:link forKey:@"link"];
        self.innerContent = nil;
    }
    if ([elementName isEqualToString:@"entry"]) {
        [self.shoppingResults addObject:self.shoppingItem];
        self.shoppingItem = nil;
        return;
    }
}

@end
