//
//  BDAudioToVideoConverter.m
//  BDAudioToVideoConverter
//
//  Created by Benny Davidovitz on 20/07/2016.
//  Copyright © 2016 xcoder.solutions. All rights reserved.
//

#import "BDAudioToVideoConverter.h"

@import CoreMedia;
@import CoreVideo;
@import CoreGraphics;
@import AVFoundation;
@import QuartzCore;

@implementation BDAudioToVideoConverter

+ (void) convertAudioFileName:(NSString *)audioFileName audioFileExtenstion:(NSString *)audioFileExt withImagesArray:(NSArray<UIImage *> *)imagesArray videoFileName:(NSString *)videoFileName withCompletionBlock:(BDAudioToVideoConverterCompletionBlock)completionBlock{
    
    NSError *error = nil;
    
    
    // set up file manager, and file videoOutputPath, remove "test_output.mp4" if it exists...
    //NSString *videoOutputPath = @"/Users/someuser/Desktop/test_output.mp4";
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *testVideoOutputPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"test_output_%@.mp4",@((NSInteger)[[NSDate new] timeIntervalSince1970])]];
    
    NSUInteger fps = 30;
    
    
    
    //////////////     end setup    ///////////////////////////////////
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:testVideoOutputPath] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    CGSize firstImageSize = [imagesArray firstObject].size;
    
    NSDictionary *videoSettings = @{
                                    AVVideoCodecKey:AVVideoCodecH264,
                                    AVVideoWidthKey:@(firstImageSize.width),
                                    AVVideoHeightKey:@(firstImageSize.height)
                                    };
    
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    //convert uiimage to CGImage.
    int frameCount = 0;
    double numberOfSecondsPerFrame = 6;
    double frameDuration = fps * numberOfSecondsPerFrame;
    
    for(UIImage * img in imagesArray)
    {
        //UIImage * img = frm._imageFrame;
        buffer = ([self pixelBufferFromCGImage:[img CGImage]]);
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 30) {
            if (adaptor.assetWriterInput.readyForMoreMediaData)  {
                //print out status:
                
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok){
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            printf("error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
    }
    
    //Finish the session:
    [videoWriterInput markAsFinished];
    [videoWriter finishWritingWithCompletionHandler:^{
        
        ////////////////////////////////////////////////////////////////////////////
        //////////////  OK now add an audio file to move file  /////////////////////
        AVMutableComposition* mixComposition = [AVMutableComposition composition];
        
        // audio input file...
        NSURL    *audio_inputFileUrl = [[NSBundle mainBundle] URLForResource:audioFileName withExtension:audioFileExt];
        
        // this is the video file that was just written above, full path to file is in --> videoOutputPath
        NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:testVideoOutputPath];
        
        // create the final video output file as MOV file - may need to be MP4, but this works so far...
        NSString *outputFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",videoFileName]];
        NSURL    *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]){
            [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
        }
        
        CMTime nextClipStartTime = kCMTimeZero;
        
        AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
        CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
        AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
        
        //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
        
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
        CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
        AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
        
        
        
        AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        //_assetExport.outputFileType = @"com.apple.quicktime-movie";
        _assetExport.outputFileType = @"public.mpeg-4";
        //NSLog(@"support file types= %@", [_assetExport supportedFileTypes]);
        _assetExport.outputURL = outputFileUrl;
        
        [_assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
            //cleanup
            if ([fileMgr fileExistsAtPath:testVideoOutputPath]) {
                [fileMgr removeItemAtPath:testVideoOutputPath error:nil];
            }
            //completion block
            if (completionBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(outputFileUrl);
                }];
            }
        }];
    }];
    
}


+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image {
    
    CGSize size = CGSizeMake(400, 200);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess){
        NSLog(@"Failed to create pixel buffer");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    //kCGImageAlphaNoneSkipFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}


@end
