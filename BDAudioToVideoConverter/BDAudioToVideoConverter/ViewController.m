//
//  ViewController.m
//  BDAudioToVideoConverter
//
//  Created by Benny Davidovitz on 20/07/2016.
//  Copyright © 2016 xcoder.solutions. All rights reserved.
//

#import "ViewController.h"
#import "BDAudioToVideoConverter.h"
@import MediaPlayer;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) NSURL *videoFileURL;

@end

@implementation ViewController

- (IBAction)createVideoAction:(UIButton *)sender {
    sender.enabled = NO;
    [_activityIndicatorView startAnimating];
    
    NSArray *imagesArray = @[
                             [UIImage imageNamed:@"image1.jpg"],
                             [UIImage imageNamed:@"image2.jpg"],
                             [UIImage imageNamed:@"image3.jpg"],
                             [UIImage imageNamed:@"image4.jpg"],
                             [UIImage imageNamed:@"image5.jpg"],

                             ];
    
    [BDAudioToVideoConverter convertAudioFileName:@"30secs" audioFileExtenstion:@"mp3" withImagesArray:imagesArray videoFileName:@"my_video" withCompletionBlock:^(NSURL * _Nonnull fileURL) {
        
        NSLog(@"%@",fileURL);
        sender.enabled = YES;
        [_activityIndicatorView stopAnimating];
        
        self.videoFileURL = fileURL;
        
        _playVideoButton.enabled = YES;
    }];
}
- (IBAction)playVideoAction:(id)sender {
    MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:_videoFileURL];
    [self presentViewController:controller animated:YES completion:NULL];
}

@end
