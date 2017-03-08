//
//  MovieCollectionViewCell.m
//  TVOSExample
//
//  Created by Christian Lysne on 13/09/15.
//  Copyright © 2015 Christian Lysne. All rights reserved.
//

#import "MovieCollectionViewCell.h"

@implementation MovieCollectionViewCell

- (void)updateCellForMovie:(Movie *)movie {
    self.movieLbl.text = movie.title;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:movie.imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.movieImg.image = [UIImage imageWithData:data];
        });
    });
}

@end
