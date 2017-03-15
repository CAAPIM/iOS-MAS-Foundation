//
//  ViewControllerMovie.m
//  SampleTvOSApp
//
//  Created by Akshay on 06/03/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import "ViewControllerMovie.h"
#import "MovieCollectionViewCell.h"
#import "Movie.h"
#import "ViewControllerMovie.h"
@interface ViewControllerMovie ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIFocusEnvironment>

@end
//bool bVar=TRUE;
@implementation ViewControllerMovie

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bVar=TRUE;
    self.movies = [NSMutableArray new];
   
    [self fetchMovies];
    // Do any additional setup after loading the view.
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Data
- (void)fetchMovies {
    
    [[Movie sharedInstance] fetchMovies:^(NSArray *movies)
    
    
    {
        
        self.movies = [NSMutableArray arrayWithArray:movies];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.collectionView reloadData];
            
        });
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma -CollectionView Protocol Methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = (CGRectGetHeight(self.view.frame)-(2*COLLECTION_VIEW_PADDING))/2;
    
    return CGSizeMake(height * (9.0/16.0), height);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCell"
                                                                                   forIndexPath:indexPath];
    cell.indexPath = indexPath;
    
    Movie *movie = [self.movies objectAtIndex:indexPath.row];
    [cell updateCellForMovie:movie];
    
    if (cell.gestureRecognizers.count == 0) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedMovie:)];
        tap.allowedPressTypes = @[[NSNumber numberWithInteger:UIPressTypeSelect]];
        [cell addGestureRecognizer:tap];
    }
    
    return cell;
}
- (BOOL)canBecomeFocused {
    return YES;
}

//-(NSArray*)preferredFocusEnvironments
//{
//    
//    
//    return @[self.btnLogout,self.collectionView];
//}


- (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator NS_AVAILABLE_IOS(9_0)
{

    

}


//-(UIView *)preferredFocusedView
//{
//    if(!self.bVar)
//
//        return self.btnLogout;
//    else
//        return nil;
//}



#pragma mark - GestureRecognizer
- (void)tappedMovie:(UITapGestureRecognizer *)gesture {
    
    if (gesture.view != nil) {
        
        MovieCollectionViewCell* cell = (MovieCollectionViewCell *)gesture.view;
        Movie *movie = [self.movies objectAtIndex:cell.indexPath.row];
        
       // ViewControllerMovie *movieVC = (id)[self.storyboard instantiateViewControllerWithIdentifier:@"Movie"];
        //movieVC.movie = movie;
        //[self presentViewController:movieVC animated:YES completion: nil];
    }
    
}

#pragma mark - Focus
- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    
    if(context.nextFocusedView==nil)
    {
    
    }
       
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 
 //
 
 if (context.previouslyFocusedView != nil) {
 
 MovieCollectionViewCell *cell = (MovieCollectionViewCell *)context.previouslyFocusedView;
 // cell.titleLabel.font = [UIFont systemFontOfSize:17];
 }
 
 if (context.nextFocusedView != nil) {
 
 MovieCollectionViewCell *cell = (MovieCollectionViewCell *)context.nextFocusedView;
 //cell.titleLabel.font = [UIFont boldSystemFontOfSize:17];
 }
*/

- (IBAction)actLogout:(id)sender {
    [[MASUser currentUser] logoutWithCompletion:^(BOOL completed, NSError *error) {
        if(!error)
        {
            //go  to main screen
        }
    }];
}
@end
