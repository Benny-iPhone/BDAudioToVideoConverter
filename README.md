# BDAudioToVideoConverter
convert audio to video with image or images

##HOW TO USE

add **BDAudioToVideoConverter.h** and **BDAudioToVideoConverter.m** to your project 
###swift developers - add **#import "BDAudioToVideoConverter.h"** to your bridging header file
###obj-c developers - add **#import "BDAudioToVideoConverter.h"** to the relevant source files.

and then 

[BDAudioToVideoConverter convertAudioFileName:@"30secs" audioFileExtenstion:@"mp3" withImagesArray:imagesArray videoFileName:@"my_video" withCompletionBlock:^(NSURL * _Nonnull fileURL) {

    //your code here
}];

inspired (and resources) from
https://github.com/caferrara/img-to-video