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
@property(weak,nonatomic)IBOutlet UILabel *nameLabel;
@property(weak,nonatomic)IBOutlet UILabel *publishedLabel;
@property(weak,nonatomic)IBOutlet UILabel *playersLabel;
@property(weak,nonatomic)IBOutlet UILabel *durationLabel;
@property(weak,nonatomic)IBOutlet UILabel *categoriesLabel;
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
@end

@implementation DetailsViewController

-(void)grabXMLData {
    NSString *detailsUrl = [NSString stringWithFormat:
                            @"http://www.boardgamegeek.com/xmlapi2/thing?type=boardgame&id=%@",
                            self.gameId];
    NSURL *url = [[NSURL alloc] initWithString:detailsUrl];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [xmlParser setDelegate:self];
    if ([xmlParser parse]) {
        self.nameLabel.text = self.gameName;
        self.publishedLabel.text = self.gamePublished;
        self.playersLabel.text = [NSString stringWithFormat:@"%@-%@",
                                  self.gamePlayers[@"max"],
                                  self.gamePlayers[@"min"]];
        self.durationLabel.text = self.gameDuration;
        self.categoriesLabel.text =
          [self.gameCategories componentsJoinedByString:@", "];
        NSURL *imgUrl = [NSURL URLWithString:self.gameThumbnail];
        NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
        self.headerImage.image = [UIImage imageWithData:imgData];
        self.descriptionTextView.text = self.gameDesc;
        [self.tableView reloadData];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
#pragma mark - View lifecycle
-(void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = @"";
    self.publishedLabel.text = @"";
    self.playersLabel.text = @"";
    self.durationLabel.text = @"";
    self.categoriesLabel.text = @"";
    self.descriptionTextView.text = @"";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // Delay XML Parse so the indicators get set.  Parsing is synchronise, and will block indicators
    [self performSelector:@selector(grabXMLData) withObject:nil afterDelay:0.5];
}
#pragma mark - NSXMLParser Delegates
-(void)  parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"item"]) {
        self.gamePlayers = [[NSMutableDictionary alloc] init];
        self.gameCategories = [[NSMutableArray alloc] init];
        return;
    }
    if ([elementName isEqualToString:@"name"]) {
        if (!self.gameName) {
            NSString *name = attributeDict[@"value"];
            if (name) self.gameName = name;
        }
        return;
    }
    if ([elementName isEqualToString:@"yearpublished"]) {
        if (!self.gamePublished) {
            NSString *published = attributeDict[@"value"];
            if (published) self.gamePublished = published;
        }
        return;
    }
    if ([elementName isEqualToString:@"minplayers"]) {
        NSString *minPlayers = attributeDict[@"value"];
        if (minPlayers) self.gamePlayers[@"min"] = minPlayers;
        return;
    }
    if ( [elementName isEqualToString:@"maxplayers"]) {
        NSString *maxPlayers = attributeDict[@"value"];
        if (maxPlayers) self.gamePlayers[@"max"] = maxPlayers;
        return;
    }
    if ([elementName isEqualToString:@"playingtime"]) {
        if (!self.gameDuration) {
            NSString *duration = attributeDict[@"value"];
            if (duration) self.gameDuration = duration;
        }
        return;
    }
    if ([elementName isEqualToString:@"thumbnail"] ||
        [elementName isEqualToString:@"description"]) {
        self.innerContent = [[NSMutableString alloc] init];
    }
    if ([elementName isEqualToString:@"link"]) {
        if ([attributeDict[@"type"] isEqualToString:@"boardgamecategory"]) {
            [self.gameCategories addObject:attributeDict[@"value"]];
        }
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.innerContent appendString:[NSMutableString stringWithString:string]];
}
-(void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"description"]) {
        //Strip white spaces
        //http://stackoverflow.com/questions/3200521/cocoa-trim-all-leading-whitespace-from-nsstring
        NSRange range =
          [self.innerContent rangeOfString:@"^\\s*"
                                   options:NSRegularExpressionSearch];
        NSString *description =
          [self.innerContent stringByReplacingCharactersInRange:range
                                                     withString:@""];
        self.gameDesc = [description gtm_stringByUnescapingFromHTML];
        self.innerContent = nil;
    }
    if ([elementName isEqualToString:@"thumbnail"]) {
        NSRange range =
          [self.innerContent rangeOfString:@"^\\s*"
                                   options:NSRegularExpressionSearch];
        self.gameThumbnail =
          [self.innerContent stringByReplacingCharactersInRange:range
                                                     withString:@""];
        self.innerContent = nil;
    }
    return;
}
@end
