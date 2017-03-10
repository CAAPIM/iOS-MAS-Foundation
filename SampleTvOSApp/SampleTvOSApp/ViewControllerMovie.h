//
//  ViewControllerMovie.h
//  SampleTvOSApp
//
//  Created by Akshay on 06/03/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <tvOS_MASFoundation/tvOS_MASFoundation.h>

#import "Movie.h"
#define COLLECTION_VIEW_PADDING 60
@interface ViewControllerMovie : UIViewController
@property (weak, nonatomic) IBOutlet  UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *movies;
@property (strong, nonatomic) Movie *movie;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
- (IBAction)actLogout:(id)sender;

@end
