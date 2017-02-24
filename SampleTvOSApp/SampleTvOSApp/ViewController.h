//
//  ViewController.h
//  SampleTvOSApp
//
//  Created by Akshay on 16/02/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <tvOS_MASFoundation/MASProximityLoginDelegate.h>
@interface ViewController : UIViewController<MASProximityLoginDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UITextView *textView;


@end

