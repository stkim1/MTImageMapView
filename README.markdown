# MTImageMapView

An UIImageView subclass to select a complex polygon map out of many.<br/>
Extremely useful for handling touches on, for example, Europe map, or an eye of owl.


## Screen Shots
<img 
src="http://blog.colorfulglue.com/wp-content/uploads/2012/10/debug.png" alt="Debug screen" title="Debug screen" style="float:left;display:block;">
<img src="http://blog.colorfulglue.com/wp-content/uploads/2012/10/normal.png" alt="Normal screen" title="Normal screen" style="float:left;display:block;margin-left:1em;">
<br/>

### Appstore Example
<img src="http://a1.mzstatic.com/us/r1000/085/Purple/v4/fe/12/1a/fe121a75-6750-4b12-78a4-49a7dba40d77/mzl.imsprsjs.320x480-75.jpg" alt="Example" title="Example" style="float:left;display:block;margin-left:1em;">
<br/>

## Features

MTImageMapView is to detect a touch event on a designated part of an image.

- Handling multiple maps on an image.<sup>1</sup> 
- Multiple MTImageMapView on a single view.
- Support Interface Builder, or progmatical initiation.
- Batch mapping. <sup>2</sup> 
- Completion block for notifying the end of mapping.<sup>3</sup> 
- Delegate to provide selected map index
- Single public class and protocol to implement.

<ol>
	<li>There is no limit but you need to be reasonable. In this example, I put around 50.</li>
	<li>Mapping takes place in background and prevents UI animation from stuttering.</li>
	<li>At the end of mapping, mapping function notifies on main thread.</li>
</ol>

## Support

- Works on iOS 4.3 ~ iOS 6.0 (tested on devices.)
- XCode 4.4 or higher required.

### TBA
- ARC.
- Zoom in/out.

## Implementation
1. Use tools like [Gimp](http://www.gimp.org/) and generate image map.
2. Copy only coordinate pairs of a map (e.g. "123,242,452,242,142,322") in NSString type.
3. Put them in an NSArray.
4. Implement MTImageMapDelegate procotol
5. pass the array to map view.
   (You can use .plist to contain such maps set and drop it into a MTImageMapView. )

```objective-c
    MTImageMapView *viewImageMap =\
        [[MTImageMapView alloc]
         initWithImage:
            [UIImage imageNamed:@"sample_image.png"]
         ];
    
    [_iewImageMap setDelegate:self];
    [self.view addSubview:viewImageMap];
    
    NSArray *arrStates = \
        [NSArray arrayWithContentsOfFile:
         [[NSBundle mainBundle]
          pathForResource:@"coordinates"
          ofType:@"plist"]];

    [viewImageMap
     setMapping:arrStates
     doneBlock:^(MTImageMapView *imageMapView) {
         NSLog(@"Mapping complete!");
     }];
```

```objective-c
	-(void)imageMapView:(MTImageMapView *)inImageMapView
	   didSelectMapArea:(NSUInteger)inIndexSelected
	{
	    [[[[UIAlertView alloc]
	     initWithTitle:@"*** State Name ***"
	     message:[stateNames objectAtIndex:inIndexSelected]
	     delegate:nil
	     cancelButtonTitle:@"Ok"
	     otherButtonTitles:nil]
	      autorelease] show];
	}
```
### LIMITS
- Delegate only receives the index of a map.
- At least 3 pairs of coordinate must be presented.
- No "rect", "circle" type map is supported. "Polygon" only at this time being.


## License
Copyright © 2012, Sung-Taek, Kim. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

<pre><code>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
</code></pre>

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.