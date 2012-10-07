//
//  DetailsViewController.m
//  BoardGeek
//
//  Created by Johnathan Pulos on 9/14/12.
//  Copyright (c) 2012 Johnathan Pulos. All rights reserved.
//

#import "DetailsViewController.h"
#import "GTMNSString+HTML.h"

@interface DetailsViewController ()
@property NSMutableDictionary *gameDetails;
@property NSMutableArray *gameCategories;
@property NSMutableString *innerContent;
@property (strong, nonatomic) IBOutlet UIImageView *headerImage;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *nameCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishedOnCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPlayersCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoriesCellLabel;
@end

@implementation DetailsViewController

-(void)grabXMLData {
    NSString *detailsUrl = [NSString stringWithFormat:@"http://www.boardgamegeek.com/xmlapi2/thing?type=boardgame&id=%@", self.gameId];
    NSURL *url = [[NSURL alloc] initWithString:detailsUrl];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [xmlParser setDelegate:self];
    BOOL success = [xmlParser parse];
    if (success) {
        [self setTableCellData];
    } else{
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)setTableCellData {
    if([self.gameDetails objectForKey:@"name"]) {
        self.nameCellLabel.text = [self.gameDetails objectForKey:@"name"];
    }
    if([self.gameDetails objectForKey:@"published"]) {
        self.publishedOnCellLabel.text = [self.gameDetails objectForKey:@"published"];
    }
    if([self.gameDetails objectForKey:@"maxPlayers"] && [self.gameDetails objectForKey:@"minPlayers"]) {
        NSString *max = [self.gameDetails objectForKey:@"maxPlayers"];
        NSString *min = [self.gameDetails objectForKey:@"minPlayers"];
        self.numPlayersCellLabel.text = [NSString stringWithFormat:@"%@-%@", min, max];
    }
    if([self.gameDetails objectForKey:@"duration"]) {
        self.durationCellLabel.text = [self.gameDetails objectForKey:@"duration"];
    }
    if (self.gameCategories) {
        self.categoriesCellLabel.text = [self.gameCategories componentsJoinedByString:@", "];
    }
    if ([self.gameDetails objectForKey:@"thumbnail"]) {
        NSURL *imgUrl = [NSURL URLWithString:[self.gameDetails objectForKey:@"thumbnail"]];
        NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
        self.headerImage.image = [UIImage imageWithData:imgData];
        
    }
    if([self.gameDetails objectForKey:@"description"]) {
        self.descriptionTextView.text = [self.gameDetails objectForKey:@"description"];
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameDetails = [[NSMutableDictionary alloc] init];
    self.gameCategories = [[NSMutableArray alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // Delay XML Parse so the indicators get set.  Parsing is synchronise, and will block indicators
    [self performSelector:@selector(grabXMLData) withObject:nil afterDelay:0.5];
}

#pragma mark
#pragma NSXMLParser Delegates

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"name"]) {
        if ([self.gameDetails objectForKey:@"name"] == nil) {
            NSString *name = [attributeDict objectForKey:@"value"];
            if (name){
                [self.gameDetails setObject:name forKey:@"name"];
            }
        }
        return;
    }
    if ([elementName isEqualToString:@"yearpublished"]) {
        if ([self.gameDetails objectForKey:@"published"] == nil) {
            NSString *published = [attributeDict objectForKey:@"value"];
            if (published){
                [self.gameDetails setObject:published forKey:@"published"];
            }
        }
        return;
    }
    if ([elementName isEqualToString:@"minplayers"]) {
        NSString *minPlayers = [attributeDict objectForKey:@"value"];
        if (minPlayers){
            [self.gameDetails setObject:minPlayers forKey:@"minPlayers"];
        }
        return;
    }
    if ( [elementName isEqualToString:@"maxplayers"]) {
        NSString *maxPlayers = [attributeDict objectForKey:@"value"];
        if (maxPlayers){
            [self.gameDetails setObject:maxPlayers forKey:@"maxPlayers"];
        }
        return;
    }
    if ([elementName isEqualToString:@"playingtime"]) {
        if ([self.gameDetails objectForKey:@"duration"] == nil) {
            NSString *duration = [attributeDict objectForKey:@"value"];
            if (duration){
                [self.gameDetails setObject:duration forKey:@"duration"];
            }
        }
        return;
    }
    if ([elementName isEqualToString:@"thumbnail"] || [elementName isEqualToString:@"description"]) {
        self.innerContent = [[NSMutableString alloc] init];
    }
    if ([elementName isEqualToString:@"link"]) {
        if ([attributeDict[@"type"] isEqualToString:@"boardgamecategory"]) {
            [self.gameCategories addObject:attributeDict[@"value"]];
        }
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSMutableString *content = [NSMutableString stringWithString:string];
    [self.innerContent appendString:content];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"description"]) {
        //Strip white spaces
        //http://stackoverflow.com/questions/3200521/cocoa-trim-all-leading-whitespace-from-nsstring
        NSRange range = [self.innerContent rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        NSString *description = [self.innerContent stringByReplacingCharactersInRange:range withString:@""];
        [self.gameDetails setObject:[description gtm_stringByUnescapingFromHTML] forKey:@"description"];
        self.innerContent = nil;
    }
    if ([elementName isEqualToString:@"thumbnail"]) {
        NSRange range = [self.innerContent rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        NSString *gameThumbnail = [self.innerContent stringByReplacingCharactersInRange:range withString:@""];
        [self.gameDetails setObject:gameThumbnail forKey:@"thumbnail"];
        self.innerContent = nil;
    }
    return;
}

@end
