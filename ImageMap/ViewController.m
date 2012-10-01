//
//  ViewController.m
//  ImageMap
//
//  Created by Almighty Kim on 9/27/12.
//  Copyright (c) 2012 Colorful Glue. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController
{
    UIScrollView         *_viewScrollStub;
    MTImageMapView       *_viewImageMap;
    NSArray              *_stateNames;
}
@synthesize viewScrollStub  = _viewScrollStub;
@synthesize viewImageMap    = _viewImageMap;
@synthesize stateNames      = _stateNames;

-(NSString *)nibName
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        
        if(result.height == 480.f)
        {
            return @"ViewController";
        }
        else
        {
            return @"ViewController-iPhone5";
        }
    }

    return @"ViewController-iPad";
}

- (void)loadView
{
    [super loadView];
	// Do any additional setup after loading the view, typically from a nib.

    self.stateNames = \
        [NSArray arrayWithContentsOfFile:
         [[NSBundle mainBundle]
          pathForResource:@"states_name"
          ofType:@"plist"]];
    
    [_viewScrollStub addSubview:_viewImageMap];
    [_viewScrollStub setContentSize:
         [_viewImageMap sizeThatFits:CGSizeZero]
	 ];
    
    NSArray *arrStates = \
        [NSArray arrayWithContentsOfFile:
         [[NSBundle mainBundle]
          pathForResource:@"states_coord"
          ofType:@"plist"]];

    [_viewImageMap
     setMapping:arrStates
     doneBlock:^(MTImageMapView *imageMapView) {
         NSLog(@"Areas are all mapped");
     }];
}

-(void)imageMapView:(MTImageMapView *)inImageMapView
   didSelectMapArea:(NSUInteger)inIndexSelected
{
    [[[[UIAlertView alloc]
     initWithTitle:@"*** State Name ***"
     message:[_stateNames objectAtIndex:inIndexSelected]
     delegate:nil
     cancelButtonTitle:@"Ok"
     otherButtonTitles:nil]
      autorelease] show];
}

@end
