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
    
    if (image != nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                         messageAsString:@"UIImage created"];
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

@end
