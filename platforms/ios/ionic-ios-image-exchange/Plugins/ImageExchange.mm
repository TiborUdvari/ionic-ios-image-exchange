//
//  ImageExchange.m
//  ionic-ios-image-exchange
//
//  Created by Tibor Udvari on 15/09/14.
//
//

#import "ImageExchange.h"

@implementation ImageExchange

- (void) echo:(CDVInvokedUrlCommand*) command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echoString = [command.arguments objectAtIndex:0];
    
    if (echoString != nil && [echoString length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                         messageAsString:echoString];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) treatImage :(CDVInvokedUrlCommand*) command
{
    CDVPluginResult* pluginResult = nil;
    NSString* imageName = [command.arguments objectAtIndex:0];
    UIImage *image = [self imageFromDocumentsWithName:imageName];
    
    cv::Mat img = [self cvMatFromUIImage: image];
    colorReduce(img);
    UIImage *processedImg = [self UIImageFromCVMat:img];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
    [UIImagePNGRepresentation(processedImg) writeToFile:filePath atomically:YES];
    
    if (image != nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                         messageAsString:imageName];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (UIImage *) imageFromDocumentsWithName : (NSString *) imageName
{
    UIImage *image = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:documentsDirectory];
    
    NSString *documentsSubpath;
    while (documentsSubpath = [direnum nextObject])
    {
        if ([documentsSubpath.lastPathComponent isEqual:imageName])
        {
            NSLog(@"The document subpath is %@", documentsSubpath);
            NSLog(@"The document directory is %@ ", documentsDirectory);
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, documentsSubpath];
            image = [UIImage imageWithContentsOfFile:filePath];
            break;
        }
    }
    return image;
}

#pragma mark - OpenCV

void colorReduce(cv::Mat &image, int div=64) {
    cv::Mat_<cv::Vec3b>::iterator it = image.begin<cv::Vec3b>();
    cv::Mat_<cv::Vec3b>::iterator itend = image.end<cv::Vec3b>();
    for ( ; it!= itend; ++it) {
        (*it)[0]= (*it)[0]/div*div + div/2;
        (*it)[1]= (*it)[1]/div*div + div/2;
        (*it)[2]= (*it)[2]/div*div + div/2;
    }
}


- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end
