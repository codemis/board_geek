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
@property NSString *gameName;
@property NSString *gameThumbnail;
@property NSString *gamePublished;
@property NSMutableDictionary *gamePlayers;
@property NSString *gameDuration;
@property NSMutableArray *gameCategories;
@property NSString *gameDesc;
@property (strong, nonatomic) IBOutlet UIImageView *headerImage;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property NSMutableString *innerContent;
@property (weak, nonatomic) IBOutlet UILabel *nameCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishedOnCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPlayersCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoriesCellLabel;
@end

@implementation DetailsViewController

-(void)grabXMLData
{
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
    if(self.gameName) {
        self.nameCellLabel.text = self.gameName;
    }
    if(self.gamePublished) {
        self.publishedOnCellLabel.text = self.gamePublished;
    }
    if(self.gamePlayers) {
        NSString *max = [self.gamePlayers objectForKey:@"max"];
        NSString *min = [self.gamePlayers objectForKey:@"min"];
        self.numPlayersCellLabel.text = [NSString stringWithFormat:@"%@-%@", min, max];
    }
    if(self.gameDuration) {
        self.durationCellLabel.text = self.gameDuration;
    }
    if (self.gameCategories) {
        self.categoriesCellLabel.text = [self.gameCategories componentsJoinedByString:@", "];
    }
    if (self.gameThumbnail) {
        NSURL *imgUrl = [NSURL URLWithString:self.gameThumbnail];
        NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
        self.headerImage.image = [UIImage imageWithData:imgData];
        
    }
    if(self.gameDesc) {
        self.descriptionTextView.text = self.gameDesc;
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // Delay XML Parse so the indicators get set.  Parsing is synchronise, and will block indicators
    [self performSelector:@selector(grabXMLData) withObject:nil afterDelay:0.5];
}

#pragma mark
#pragma NSXMLParser Delegates

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"item"]) {
        self.gamePlayers = [[NSMutableDictionary alloc] init];
        self.gameCategories = [[NSMutableArray alloc] init];
        return;
    }
    if ([elementName isEqualToString:@"name"]) {
        if (!self.gameName) {
            NSString *name = [attributeDict objectForKey:@"value"];
            if (name){
                self.gameName = name;
            }
        }
        return;
    }
    if ([elementName isEqualToString:@"yearpublished"]) {
        if (!self.gamePublished) {
            NSString *published = [attributeDict objectForKey:@"value"];
            if (published){
                self.gamePublished = published;
            }
        }
        return;
    }
    if ([elementName isEqualToString:@"minplayers"]) {
        NSString *minPlayers = [attributeDict objectForKey:@"value"];
        if (minPlayers){
            [self.gamePlayers setObject:minPlayers forKey:@"min"];
        }
        return;
    }
    if ( [elementName isEqualToString:@"maxplayers"]) {
        NSString *maxPlayers = [attributeDict objectForKey:@"value"];
        if (maxPlayers){
            [self.gamePlayers setObject:maxPlayers forKey:@"max"];
        }
        return;
    }
    if ([elementName isEqualToString:@"playingtime"]) {
        if (!self.gameDuration) {
            NSString *duration = [attributeDict objectForKey:@"value"];
            if (duration){
                self.gameDuration = duration;
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

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSMutableString *content = [NSMutableString stringWithString:string];
    [self.innerContent appendString:content];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"description"]) {
        //Strip white spaces
        //http://stackoverflow.com/questions/3200521/cocoa-trim-all-leading-whitespace-from-nsstring
        NSRange range = [self.innerContent rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        NSString *description = [self.innerContent stringByReplacingCharactersInRange:range withString:@""];
        self.gameDesc = [description gtm_stringByUnescapingFromHTML];
        self.innerContent = nil;
    }
    if ([elementName isEqualToString:@"thumbnail"]) {
        NSRange range = [self.innerContent rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        self.gameThumbnail = [self.innerContent stringByReplacingCharactersInRange:range withString:@""];
        self.innerContent = nil;
    }
    return;
}

@end
