#import <Cocoa/Cocoa.h>

@class ORImageInputView, ORImageOutputView;

@interface ORAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet ORImageInputView *sourceImageView;
@property (assign) IBOutlet ORImageOutputView *macroImageView;

@property (strong) NSString *sourceImagePath;
@property (strong) NSString *topText;
@property (strong) NSString *bottomText;

@property (strong) NSData  *macroImageData;
@property (strong) NSImage *macroImage;

@end
