/*
 *
 * BSD license follows (http://www.opensource.org/licenses/bsd-license.php)
 *
 * Copyright (c) 2012-2013 Sung-Taek, Kim <stkim1@colorfulglue.com> All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * Redistributions of  source code  must retain  the above  copyright notice,
 * this list of  conditions and the following  disclaimer. Redistributions in
 * binary  form must  reproduce  the  above copyright  notice,  this list  of
 * conditions and the following disclaimer  in the documentation and/or other
 * materials  provided with  the distribution.  Neither the  name of  Sung-Ta
 * ek kim nor the names of its contributors may be used to endorse or promote
 * products  derived  from  this  software  without  specific  prior  written
 * permission.  THIS  SOFTWARE  IS  PROVIDED BY  THE  COPYRIGHT  HOLDERS  AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
 * NOT LIMITED TO, THE IMPLIED  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A  PARTICULAR PURPOSE  ARE DISCLAIMED.  IN  NO EVENT  SHALL THE  COPYRIGHT
 * HOLDER OR  CONTRIBUTORS BE  LIABLE FOR  ANY DIRECT,  INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY,  OR CONSEQUENTIAL DAMAGES (INCLUDING,  BUT NOT LIMITED
 * TO, PROCUREMENT  OF SUBSTITUTE GOODS  OR SERVICES;  LOSS OF USE,  DATA, OR
 * PROFITS; OR  BUSINESS INTERRUPTION)  HOWEVER CAUSED AND  ON ANY  THEORY OF
 * LIABILITY,  WHETHER  IN CONTRACT,  STRICT  LIABILITY,  OR TORT  (INCLUDING
 * NEGLIGENCE  OR OTHERWISE)  ARISING  IN ANY  WAY  OUT OF  THE  USE OF  THIS
 * SOFTWARE,   EVEN  IF   ADVISED  OF   THE  POSSIBILITY   OF  SUCH   DAMAGE.
 *
 */

#import "ViewController.h"


@implementation ViewController
{
    __unsafe_unretained UIScrollView         *_viewScrollStub;
    __unsafe_unretained MTImageMapView       *_viewImageMap;
    __strong			NSArray              *_stateNames;
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
    [[[UIAlertView alloc]
     initWithTitle:@"*** State Name ***"
     message:[_stateNames objectAtIndex:inIndexSelected]
     delegate:nil
     cancelButtonTitle:@"Ok"
     otherButtonTitles:nil] show];
}

@end
