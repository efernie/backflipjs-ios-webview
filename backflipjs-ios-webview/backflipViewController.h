//
//  backflipViewController.h
//  backflipjs-ios-webview
//
//  Created by Eric Fernberg on 5/18/14.
//  Copyright (c) 2014 Eric Fernberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface backflipViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *mobileWebView;

@property NSString *baseURL;
@property NSString *webScheme;

@property (assign) BOOL isReachable;

@end
