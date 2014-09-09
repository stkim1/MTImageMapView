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


#import "MTImageMapView.h"

#pragma mark MACRO

#ifdef DEBUG
    #define MTLOG(args...)	NSLog(@"%@",[NSString stringWithFormat:args])
#else
    #define MTLOG(args...)
#endif

#define MTASSERT(cond,desc...) NSAssert(cond, @"%@", [NSString stringWithFormat: desc])
#if __has_feature(objc_arc)
    #define SAFE_DEALLOC_CHECK(__POINTER)
#else
    #define SAFE_DEALLOC_CHECK(__POINTER) {[super dealloc];}
#endif

#define IS_NULL_STRING(__POINTER) \
                        (__POINTER == nil || \
                        __POINTER == (NSString *)[NSNull null] || \
                        ![__POINTER isKindOfClass:[NSString class]] || \
                        ![__POINTER length])



#pragma mark - INTERFACES

#pragma  mark Debug View
#ifdef DEBUG_MAP_AREA
@interface MTMapDebugView : UIView
@property (nonatomic, assign) NSMutableArray *mapAreasToDebug;
@property (nonatomic)   CGPoint aTouchPoint;
@end
#endif

#pragma mark Map Area Model
@interface MTMapArea : NSObject
@property (nonatomic, retain)   UIBezierPath        *mapArea;
@property (nonatomic, readonly) NSUInteger          areaID;
-(id)initWithCoordinate:(NSString*)inStrCoordinate areaID:(NSInteger)inAreaID;
-(BOOL)isAreaSelected:(CGPoint)inPointTouch;
@end

#pragma mark Image Map View
@interface MTImageMapView()
@property (atomic, retain) NSMutableArray *mapAreas;
-(void)_finishConstructionWithImage:(UIImage *)inImage;
-(void)_performHitTestOnArea:(NSValue *)inTouchPoint;

#ifdef DEBUG_MAP_AREA
	#if __has_feature(objc_arc)
		@property (nonatomic, strong) MTMapDebugView *viewDebugPath;
	#else
		@property (nonatomic, retain) MTMapDebugView *viewDebugPath;
	#endif
#endif

@end

#pragma mark - IMPLEMENTATIONS
#pragma mark -
#pragma mark Image Map View
@implementation MTImageMapView
{
#if __has_feature(objc_arc)
	__unsafe_unretained id<MTImageMapDelegate>  _delegate;
#else
	id<MTImageMapDelegate>  _delegate;
#endif
}

@synthesize mapAreas;
@synthesize delegate = _delegate;

#ifdef DEBUG_MAP_AREA
@synthesize viewDebugPath;
#endif

-(id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if(self)
    {
        [self _finishConstructionWithImage:image];
    }
    return self;
}

-(id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if(self)
    {
        [self _finishConstructionWithImage:image];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self _finishConstructionWithImage:self.image];
    }
    return self;
}


-(void)dealloc
{
#ifdef DEBUG_MAP_AREA
    self.viewDebugPath = nil;
#endif

    self.mapAreas = nil;
    self.delegate = nil;

	SAFE_DEALLOC_CHECK(self);
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

// public methods
-(void)setMapping:(NSArray *)inMappingArea
        doneBlock:(void (^)(MTImageMapView *imageMapView))inBlockDone
{
    MTASSERT(inMappingArea != nil, @"mapping array cannot be nil");
    MTASSERT([inMappingArea count] != 0, @"mapping array should have element");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_group_t group = dispatch_group_create();

    NSUInteger countArea = [inMappingArea count];
    NSString* aStrArea = nil;

    [self.mapAreas removeAllObjects];
    
#ifdef DEBUG_MAP_AREA
    [self.viewDebugPath setMapAreasToDebug:[self mapAreas]];
#endif
    
    __block typeof (self) belf = self;
    for(NSUInteger index = 0; index < countArea; index++)
    {
        aStrArea = [inMappingArea objectAtIndex:index];
        
        dispatch_group_async(group,queue,^{
            
            @autoreleasepool {
                                
                MTMapArea* anArea = \
                    [[MTMapArea alloc]
                     initWithCoordinate:aStrArea
                     areaID:index];

                [[belf mapAreas] addObject:anArea];

#if !__has_feature(objc_arc)
                [anArea release];
#endif
            }
            
        });
    }
    
    if(inBlockDone != NULL)
    {
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            inBlockDone(belf);
        });
    }
    
#if !OS_OBJECT_USE_OBJC
	dispatch_release(queue);
    dispatch_release(group);
#endif
}

// private methods
-(void)_finishConstructionWithImage:(UIImage *)inImage
{
    CGSize imageSize = [inImage size];
    CGRect imageFrame = (CGRect){CGPointZero,imageSize};

    // set frame to size of image
    [self setFrame:imageFrame];
    
    //do not change width or height by aytoresizing
    UIViewAutoresizing sizingOption = [self autoresizingMask];
    UIViewAutoresizing sizingFilter = \
    (UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight) ^ (NSUInteger)(-1);
    sizingOption &= sizingFilter;
    [self setAutoresizingMask:sizingOption];
    
    self.mapAreas = [NSMutableArray arrayWithCapacity:0];
    [self setUserInteractionEnabled:YES];
    [self setMultipleTouchEnabled:NO];
    
#ifdef DEBUG_MAP_AREA
    self.viewDebugPath = \
		[[MTMapDebugView alloc]
		 initWithFrame:imageFrame];
    [self.viewDebugPath setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.viewDebugPath];

#if !__has_feature(objc_arc)
    [self.viewDebugPath release];
#endif

#endif
}

-(void)_performHitTestOnArea:(NSValue *)inTouchPoint
{
    MTASSERT(inTouchPoint != nil, @"touch point is null");
    
    CGPoint     aTouchPoint     = [inTouchPoint CGPointValue];
    NSArray*    areaArray       = [self mapAreas];

    for(MTMapArea *anArea in areaArray)
    {
        if([anArea isAreaSelected:aTouchPoint])
        {
            if(_delegate != nil
               && [_delegate conformsToProtocol:@protocol(MTImageMapDelegate)]
               && [_delegate
                   respondsToSelector:
                   @selector(imageMapView:didSelectMapArea:)])
            {
                [_delegate
                 imageMapView:self
                 didSelectMapArea:anArea.areaID];
            }
            break;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];

    // cancel previous touch ended event
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	CGPoint touchPoint  = \
        [[touches anyObject] locationInView:self];

    NSValue*    touchValue =\
        [NSValue
         valueWithCGPoint:touchPoint];

    // perform new one
    [self
     performSelector:@selector(_performHitTestOnArea:)
     withObject:touchValue
     afterDelay:0.1];

#ifdef DEBUG_MAP_AREA
    [self.viewDebugPath setATouchPoint:touchPoint];
    [self.viewDebugPath setNeedsDisplay];
#endif
}
@end


#pragma  mark Debug View
#ifdef DEBUG_MAP_AREA
@implementation MTMapDebugView
@synthesize mapAreasToDebug = _mapAreasToDebug;
@synthesize aTouchPoint = _aTouchPoint;

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
    
    if(_mapAreasToDebug == nil || ![_mapAreasToDebug count])
        return;

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	// drawing path
	CGContextSetLineWidth(context, 1.0);
	UIColor *lineColor = [UIColor blueColor];
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetFillColorWithColor(context, lineColor.CGColor);
    
	CGContextDrawPath(context, kCGPathFillStroke);
	CGContextSetLineJoin(context,kCGLineJoinRound);
	CGContextSetLineCap(context,kCGLineCapButt);
	CGContextSetBlendMode(context,kCGBlendModePlusLighter);
    
	CGRect dotRect = \
        CGRectMake(_aTouchPoint.x - 3, _aTouchPoint.y - 3.0, 5.0, 5.0);
	CGContextAddEllipseInRect(context, dotRect);

    CGContextDrawPath(context, kCGPathStroke);
    for(MTMapArea *anArea in _mapAreasToDebug)
    {
        CGContextAddPath(context, anArea.mapArea.CGPath);
    }

	CGContextStrokePath(context);
	CGContextRestoreGState(context);
}
@end
#endif


#pragma mark Map Area Model
@implementation MTMapArea
{
    UIBezierPath        *_mapArea;
    NSUInteger          _areaID;
}
@synthesize mapArea         = _mapArea;
@synthesize areaID          = _areaID;

-(id)initWithCoordinate:(NSString*)inStrCoordinate areaID:(NSInteger)inAreaID
{
    self = [super init];
    
    if(self != nil)
    {
        // set area id
        _areaID = inAreaID;
        
        // create map area out of coordinate string
        MTASSERT(!IS_NULL_STRING(inStrCoordinate)
                 ,@"*** string must contain area coordinates ***");
        
        NSArray*    arrAreaCoordinates = \
        [inStrCoordinate componentsSeparatedByString:@","];
        
        NSUInteger  countTotal      = [arrAreaCoordinates count];
        NSUInteger  countCoord      = countTotal/2;
        BOOL        isFirstPoint    = YES;
        
        // # of coordinate must be in even numbers.
        //http://stackoverflow.com/questions/160930/how-do-i-check-if-an-integer-is-even-or-odd
        MTASSERT(!(countTotal % 2), @"total # of coordinates must be even. count %lu",(unsigned long)countCoord);
        MTASSERT((3 <= countCoord), @"At least, three dots to represent an area");
        
        // add points to bezier path
        UIBezierPath  *path         = [UIBezierPath new];
        
        for(NSUInteger i = 0; i < countCoord; i++)
        {
            NSUInteger index = i<<1;
            CGPoint aPoint = \
            CGPointMake([[arrAreaCoordinates
                          objectAtIndex:index] floatValue]
                        , [[arrAreaCoordinates
                            objectAtIndex:index+1] floatValue]);
            
            if(isFirstPoint)
            {
                [path moveToPoint:aPoint];
                isFirstPoint = NO;
            }
            
            [path addLineToPoint:aPoint];
            
        }
        
        [path closePath];
        
        self.mapArea = path;
#if !__has_feature(objc_arc)
        [path release];
#endif
    }
    return self;
}

-(BOOL)isAreaSelected:(CGPoint)inPointTouch
{
    return CGPathContainsPoint(self.mapArea.CGPath,NULL,inPointTouch,false);
}

-(void)dealloc
{
    self.mapArea = nil;
	SAFE_DEALLOC_CHECK(self);
}
@end
