//
//  ViewController.m
//  BoardGeek
//
//  Created by Johnathan Pulos on 8/30/12.
//  Copyright (c) 2012 Johnathan Pulos. All rights reserved.
//
#import "ViewController.h"
#import "DetailsViewController.h"

@interface ViewController () <NSXMLParserDelegate,UIGestureRecognizerDelegate>

@end

@implementation ViewController

-(void)recommendGame:(NSString *)game {
    [self updateChatBox:[NSString stringWithFormat:@"Have you played \"%@\"?",
                         game]];
}
-(void)updateChatBox:(NSString *)newText {
    self.chatBox.text = newText;
}
-(void)grabXMLData {
    NSString *boardGameGeekAPIHotSearch =
      @"http://www.boardgamegeek.com/xmlapi2/hot?type=boardgame";
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:
                              [NSURL URLWithString:boardGameGeekAPIHotSearch]];
    [xmlParser setDelegate:self];
    if ([xmlParser parse] && [self.boardGameItemsArray count] > 0) {
        int rndIndex = arc4random()%[self.boardGameItemsArray count];
        self.selectedBoardGame = self.boardGameItemsArray[rndIndex];
        [self recommendGame:self.selectedBoardGame[@"itemName"]];
        self.detailsButton.hidden = NO;
    } else [self updateChatBox:@"Brain fart...Try again..."];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    if ([self.selectedBoardGame count] > 0)
        [self recommendGame:self.selectedBoardGame[@"itemName"]];
    self.boardGameItemsArray = [[NSMutableArray alloc] init];
    self.detailsButton.hidden = YES;
}
#pragma mark - NSXMLParser Delegates
-(void)  parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"item"]) {
        self.boardGameItemData = [[NSMutableDictionary alloc] init];
        if (!self.boardGameItemId) {
            NSString *itemId = attributeDict[@"id"];
            if (itemId) self.boardGameItemId = itemId;
        }
        return;
    }
    if ([elementName isEqualToString:@"thumbnail"]) {
        if (!self.boardGameThumbnail) {
            NSString *thumbnail = attributeDict[@"value"];
            if (thumbnail) self.boardGameThumbnail = thumbnail;
        }
        return;
    }
    if ([elementName isEqualToString:@"name"]) {
        if (!self.boardGameName) {
            NSString *name = attributeDict[@"value"];
            if (name) self.boardGameName = name;
        }
        return;
    }    
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
}
-(void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"thumbnail"]) {
        self.boardGameItemData[@"thumbnail"] = self.boardGameThumbnail;
        self.boardGameThumbnail = nil;
        return;
    }
    if ([elementName isEqualToString:@"name"]) {
        self.boardGameItemData[@"itemName"] = self.boardGameName;
        self.boardGameName = nil;
        return;
    }
    if ([elementName isEqualToString:@"item"]) {
        self.boardGameItemData[@"itemID"] = self.boardGameItemId;
        self.boardGameItemId = nil;
        // We have gone through a single item, so add it to an array
        [self.boardGameItemsArray addObject:self.boardGameItemData];
        return;
    }
}
#pragma mark - UIGesture Delegates
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
      shouldReceiveTouch:(UITouch *)touch {
    return [touch.view isKindOfClass:[UIButton class]] ? NO : YES;
}
#pragma mark - IBActions
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender {
    [self updateChatBox:@"Thinking...Hmmmmm....."];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.detailsButton.hidden = YES;
    // Delay XML parse so indicator starts. Parsing is synchronous and will
    // block indicators
    [self performSelector:@selector(grabXMLData) withObject:nil afterDelay:0.5];
}
#pragma mark - Segue Delegates
- (IBAction)done:(UIStoryboardSegue *)segue {
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"getDetails"]) {
        DetailsViewController *controller = segue.destinationViewController;
        controller.gameId = self.selectedBoardGame[@"itemID"];
    }
}
@end
