# MTImageMapView

An UIImageView subclass to select a complex polygon map out of many.<br/>
Extremely useful for handling touches on, for example, Europe map, or an eye of owl.


## Screen Shots
<img 
src="http://farm9.staticflickr.com/8484/8230660409_79df1af06b.jpg" alt="Debug screen" title="Debug screen" style="float:left;display:block;">
<img src="http://farm9.staticflickr.com/8342/8231732162_28bb9033a8.jpg" alt="Normal screen" title="Normal screen" style="float:left;display:block;margin-left:1em;">
<br/>

## Features

- Handling multiple maps on an image.<sup>1</sup> 
- Multiple MTImageMapView on a single view
- Support Interface Builder, or progmatical initiation
- Batch mapping. <sup>2</sup> 
- Completion block for notifying the end of mapping.<sup>3</sup> 
- Delegate to provide selected map index
- Single public class and protocol to implement
- Debug mode to superimpose maps on an image

<ol>
	<li>There is no limit but you need to be reasonable. In this example, I put around 50.</li>
	<li>Mapping takes place in background and prevents UI animation from stuttering.</li>
	<li>At the end of mapping, mapping function notifies on main thread.</li>
</ol>

## Support

- Works on iOS 4.3 ~ iOS 6.0 (tested on devices.)
- XCode 4.4 or higher required.

### TBA
- ~~ARC.~~ 
- Zoom in/out.

## Implementation
1. Use tools like [Gimp](http://www.gimp.org/) and generate a image map.
2. Copy only coordinate pairs of the map (e.g. "123,242,452,242,142,322") in NSString type.
3. Put the strings in an NSArray.
4. Instantiate MTImageMapView and implement MTImageMapDelegate procotol
5. pass the array to the map view.
   (You can use .plist to pass a map batch to a MTImageMapView. )

```objective-c
    MTImageMapView *viewImageMap =\
        [[MTImageMapView alloc]
         initWithImage:
            [UIImage imageNamed:@"sample_image.png"]
         ];

    [viewImageMap setDelegate:self];
    [self.view addSubview:viewImageMap];
    
    NSArray *arrStates = \
        [NSArray arrayWithObjects:
         @"542,94,568,94,568,111,542,111"
         @"555,150,574,150,574,161,555,161"
         @"535,149,551,149,551,159,535,159"
         ,nil];

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
- Coordinates must be provided in pairs.
- At least 3 pairs of coordinates must be presented.
- No "rect", "circle" type map is supported. "Polygon" only at this time being.
- Starting from iOS 6.0, dispatch objects are Object-C objects, meaning when you are to go with ARC, dispatch objects too are managed by ARC. For backward compatibility issue, I do not support ARC at this point. You can read more detail at [Does ARC support dispatch queues?](http://stackoverflow.com/questions/8618632/does-arc-support-dispatch-queues)

## Credits
US states image and all coordinates are credited to [Illinois Center for Information Technology and Web Accessibility](http://html.cita.illinois.edu/text/map/map-example.php).</a>

## License
Copyright © 2012, Sung-Taek, Kim. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

<pre><code>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
</code></pre>

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.