#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
            @"/Users/keith/Pictures/x/tumblr_lof3frs5nL1qgc9j3o1_1280.jpg", @"image",
            @"tits",                                                        @"top",
            @"fuck yeah",                                                   @"bottom",
            [NSNumber numberWithBool:YES],                                  @"forceUppercase",
            @"Impact",                                                      @"font",
            [NSNumber numberWithDouble:48.0],                               @"fontSize",
            [NSNumber numberWithDouble:6.0],                                @"outlineSize",
            [NSNumber numberWithInt:512],                                   @"outputSize",
            (__bridge NSString *)kUTTypePNG,                                @"outputType",
            nil];
        NSUserDefaults *D = [NSUserDefaults standardUserDefaults];
        [D registerDefaults:options];
        
        for (int i = 1; i < argc; ++i)
        {
            if (strcmp(argv[i], "-help") == 0 ||
                strcmp(argv[i], "-h") == 0 ||
                strcmp(argv[i], "--help") == 0)
            {
                for (id k in options)
                {
                    printf("-%s (default: \"%s\")\n", [[[k description] stringByPaddingToLength:20 withString:@" " startingAtIndex:0] UTF8String], [[[D objectForKey:k] description] UTF8String]);
                }
                return EXIT_SUCCESS;
            }
        }

        CTFontRef font = CTFontCreateWithName(
            (__bridge CFStringRef)[D stringForKey:@"font"],
            [D doubleForKey:@"fontSize"],
            NULL);
        CTParagraphStyleSetting settings[] =
        {
            {
                .spec = kCTParagraphStyleSpecifierAlignment,
                .valueSize = sizeof(CTTextAlignment),
                .value = (CTTextAlignment[]){ kCTCenterTextAlignment },
            }
        };
        CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        CGColorRef none  = CGColorCreate(colorSpace, (CGFloat[]){ 0.0, 0.0, 0.0, 0.0 });
        CGColorRef black = CGColorCreate(colorSpace, (CGFloat[]){ 0.0, 0.0, 0.0, 1.0 });
        CGColorRef white = CGColorCreate(colorSpace, (CGFloat[]){ 1.0, 1.0, 1.0, 1.0 });
        NSDictionary *outlineAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)font,  kCTFontAttributeName,
            (__bridge id)black, kCTStrokeColorAttributeName,
            [NSNumber numberWithDouble:2 * [D doubleForKey:@"outlineSize"]],
                                kCTStrokeWidthAttributeName,
            (__bridge id)style, kCTParagraphStyleAttributeName,
            nil];
        NSDictionary *fillAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)font,  kCTFontAttributeName,
            (__bridge id)white, kCTForegroundColorAttributeName,
            (__bridge id)none,  kCTStrokeColorAttributeName,
            [NSNumber numberWithDouble:-2 * [D doubleForKey:@"outlineSize"]],
                                kCTStrokeWidthAttributeName,
            (__bridge id)style, kCTParagraphStyleAttributeName,
            nil];

        NSString *imagePath  = [D stringForKey:@"image"];
        NSString *topText    = [D stringForKey:@"top"];
        NSString *bottomText = [D stringForKey:@"bottom"];
        
        if ([D boolForKey:@"forceUppercase"])
        {
            topText = [topText uppercaseString];
            bottomText = [bottomText uppercaseString];
        }
        
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
        if (!imageSource || !CGImageSourceGetCount(imageSource))
        {
            NSLog(@"No images at %@", imagePath);
            return EXIT_FAILURE;
        }
        
        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
        if (!image)
        {
            NSLog(@"Couldn't load image at %@", imagePath);
            return EXIT_FAILURE;
        }
        
        size_t w = CGImageGetWidth(image);
        size_t h = CGImageGetHeight(image);
        
        size_t newWidth, newHeight;
        if (w > h)
        {
            newWidth = [D integerForKey:@"outputSize"];
            newHeight = rinttol(((double)h / (double)w) * newWidth);
        }
        else
        {
            newHeight = [D integerForKey:@"outputSize"];
            newWidth = rinttol(((double)w / (double)h) * newHeight);
        }
        
        CGContextRef context = CGBitmapContextCreate(NULL, newWidth, newHeight, 8, newWidth * 4, colorSpace, kCGImageAlphaNoneSkipFirst);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), image);
        
        void (^draw)(NSString *, NSDictionary *, size_t (^)(size_t)) = ^(NSString *s, NSDictionary *a, size_t (^y)(size_t h))
        {
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:s attributes:a];
            CFRange range = CFRangeMake(0, [string length]);
            CTFramesetterRef setter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
            CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(setter, range, NULL, CGSizeMake(newWidth, newHeight), NULL);
            CGPathRef path = CGPathCreateWithRect(CGRectMake(0, y(size.height), newWidth, size.height), NULL);
            CTFrameRef frame = CTFramesetterCreateFrame(setter, range, path, NULL);
            CTFrameDraw(frame, context);
        };
        
        draw(topText,    outlineAttributes, ^(size_t h) { return newHeight - h; });
        draw(topText,    fillAttributes,    ^(size_t h) { return newHeight - h; });
        draw(bottomText, outlineAttributes, ^(size_t h) { return (size_t)0; });
        draw(bottomText, fillAttributes,    ^(size_t h) { return (size_t)0; });
        
        NSMutableData *data = [NSMutableData data];
        CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data, (__bridge CFStringRef)[D stringForKey:@"outputType"], 1, NULL);
        CGImageDestinationAddImage(dest, CGBitmapContextCreateImage(context), NULL);
        CGImageDestinationFinalize(dest);
        
        fwrite([data bytes], [data length], 1, stdout);
    }
    
    return EXIT_SUCCESS;
}
