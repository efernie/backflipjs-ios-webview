//
//  backflipViewController.h
//  backflipjs-ios-webview
//
//  Created by Eric Fernberg on 5/18/14.
//  Copyright (c) 2014 Eric Fernberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface backflipViewController : UIViewController <UIWebViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIWebView *mobileWebView;

@property NSString *baseURL;
@property NSString *webScheme;

@property (assign) BOOL isReachable;

@end
