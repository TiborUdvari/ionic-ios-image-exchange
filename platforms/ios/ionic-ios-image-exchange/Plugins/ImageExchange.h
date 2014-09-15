//
//  ImageExchange.h
//  ionic-ios-image-exchange
//
//  Created by Tibor Udvari on 15/09/14.
//
//

#import <Cordova/CDV.h>

@interface ImageExchange : CDVPlugin

- (void) echo :(CDVInvokedUrlCommand*) command;

- (void) treatImage :(CDVInvokedUrlCommand*) command;

@end
