//
//  ViewController.h
//  ImageMap
//
//  Created by Almighty Kim on 9/27/12.
//  Copyright (c) 2012 Colorful Glue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTImageMapView.h"

@interface ViewController : UIViewController
<MTImageMapDelegate>
@property (nonatomic, assign) IBOutlet UIScrollView         *viewScrollStub;
@property (nonatomic, assign) IBOutlet MTImageMapView       *viewImageMap;
@property (nonatomic, retain)          NSArray              *stateNames;
@end
