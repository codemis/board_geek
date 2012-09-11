//
//  ViewController.m
//  BoardGeek
//
//  Created by Johnathan Pulos on 8/30/12.
//  Copyright (c) 2012 Johnathan Pulos. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)updateChatBox:(NSString *)newText
{
    self.chatBox.text = newText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BOOL isEmpty = ([self.selectedBoardGame count] == 0);
    if (!isEmpty) {
        NSString *title = [self.selectedBoardGame objectForKey:@"itemName"];
        [self updateChatBox:[NSString stringWithFormat:@"Have you played \"%@\"?", title]];
    }
    [self setBoardGameItemsArray:[[NSMutableArray alloc] init]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma NSXMLParser Delegates

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"item"]) {
        [self setBoardGameItemData:[[NSMutableDictionary alloc] init]];
        if (!self.boardGameItemId) {
            NSString *itemId = [attributeDict objectForKey:@"id"];
            if (itemId){
             self.boardGameItemId = itemId;
            }
        }
        return;
    }
    if ( [elementName isEqualToString:@"thumbnail"]) {
        if (!self.boardGameThumbnail) {
            NSString *thumbnail = [attributeDict objectForKey:@"value"];
            if (thumbnail){
                self.boardGameThumbnail = thumbnail;
            }
        }
        return;
    }
    if ( [elementName isEqualToString:@"name"]) {
        if (!self.boardGameName) {
            NSString *name = [attributeDict objectForKey:@"value"];
            if (name){
                self.boardGameName = name;
            }
        }
        return;
    }

    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"thumbnail"]) {
        [self.boardGameItemData setObject:self.boardGameThumbnail forKey:@"thumbnail"];
        self.boardGameThumbnail = nil;
        return;
    }
    if ([elementName isEqualToString:@"name"]) {
        [self.boardGameItemData setObject:self.boardGameName forKey:@"itemName"];
        self.boardGameName = nil;
        return;
    }
    if ([elementName isEqualToString:@"item"]) {
        [self.boardGameItemData setObject:self.boardGameItemId forKey:@"itemID"];
        self.boardGameItemId = nil;
        // We have gone through a sing item, so add it to an array
        [self.boardGameItemsArray addObject:self.boardGameItemData];
        return;
    }

}

#pragma mark
#pragma UIGesture Delegates

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark
#pragma IBActions
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender {
    [self updateChatBox:@"Thinking...Hmmmmm....."];
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.boardgamegeek.com/xmlapi2/hot?type=boardgame"];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [xmlParser setDelegate:self];
    BOOL success = [xmlParser parse];
    if (success) {
        if ([self.boardGameItemsArray count] == 0) {
            [self updateChatBox:@"Brain fart...Try again..."];
            return;
        }
        int rndIndex = arc4random()%[self.boardGameItemsArray count];
        self.selectedBoardGame = [self.boardGameItemsArray objectAtIndex:rndIndex];
        NSString *title = [self.selectedBoardGame objectForKey:@"itemName"];
        [self updateChatBox:[NSString stringWithFormat:@"Have you played \"%@\"?", title]];
    } else{
        [self updateChatBox:@"Brain fart...Try again..."];
    }
}
@end
