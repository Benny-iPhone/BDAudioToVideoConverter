//
//  BDAudioToVideoConverter.h
//  BDAudioToVideoConverter
//
//  Created by Benny Davidovitz on 20/07/2016.
//  Copyright © 2016 xcoder.solutions. All rights reserved.
//

@import UIKit;

typedef void(^BDAudioToVideoConverterCompletionBlock)( NSURL * _Nonnull fileURL);


@interface BDAudioToVideoConverter : NSObject

/**
 *  @param audioFileName - audio file you would like to add to the video
 *  @param audioFileExt - that file extenstion
 *  @param imagesArray  - should not be empty, video size will be based on first image size
 *  @param videoFileName - the file name without extenstion, for example: @"my_video", the extenstion will be mp4
 */
+ (void) convertAudioFileName:(nonnull NSString *)audioFileName audioFileExtenstion:(nonnull NSString *)audioFileExt withImagesArray:(nonnull NSArray <UIImage *>*)imagesArray videoFileName:(nonnull NSString *)videoFileName withCompletionBlock:(nullable BDAudioToVideoConverterCompletionBlock)completionBlock;


/**
 *  @param fileURL - audio file local url
 *  @param imagesArray  - should not be empty, video size will be based on first image size
 *  @param videoFileName - the file name without extenstion, for example: @"my_video", the extenstion will be mp4
 */
+ (void) convertAudioFileURL:(nonnull NSURL *)fileURL withImagesArray:(nonnull NSArray <UIImage *>*)imagesArray videoFileName:(nonnull NSString *)videoFileName withCompletionBlock:(nullable BDAudioToVideoConverterCompletionBlock)completionBlock;

@end
