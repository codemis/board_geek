//
//  ViewController.h
//  BoardGeek
//
//  Created by Johnathan Pulos on 8/30/12.
//  Copyright (c) 2012 Johnathan Pulos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSXMLParserDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITextView *chatBox;
@property NSMutableArray *boardGameItemsArray;
@property NSMutableDictionary *boardGameItemData;
@property NSString *boardGameItemId;
@property NSString *boardGameThumbnail;
@property NSString *boardGameName;
@property NSMutableDictionary *selectedBoardGame;
@property (strong, nonatomic) IBOutlet UIButton *detailsButton;
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender;
- (IBAction)done:(UIStoryboardSegue *)segue;
@end
