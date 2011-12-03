#import "ORAppDelegate.h"
#import "ORImageInputView.h"
#import "ORImageOutputView.h"

@implementation ORAppDelegate

@synthesize window           = _window;
@synthesize sourceImageView  = _sourceImageView;
@synthesize macroImageView   = _macroImageView;

@synthesize sourceImagePath   = _sourceImagePath;
@synthesize topText           = _topText;
@synthesize bottomText        = _bottomText;

@synthesize macroImageData    = _macroImageData;
@synthesize macroImage        = _macroImage;

- (id)init
{
    self = [super init];
    if (self == nil)
    {
        return nil;
    }
    
    [self addObserver:self forKeyPath:@"sourceImagePath" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"topText" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"bottomText" options:0 context:NULL];
    
    return self;
}

- (void)awakeFromNib
{
    [self.sourceImageView addObserver:self forKeyPath:@"imagePath" options:0 context:NULL];
}

- (void)render
{
    NSLog(@"render");
    
    NSString *top    = self.topText    ? self.topText    : @"";
    NSString *bottom = self.bottomText ? self.bottomText : @"";
    NSString *fileName = @"ORLY.png";
    if ([top length]) fileName = top;
    if ([bottom length] && [top length]) fileName = [fileName stringByAppendingString:@"; "];
    if ([bottom length]) fileName = [fileName stringByAppendingString:bottom];
    
    NSMutableArray *arguments = [NSMutableArray array];
    
    if (!self.sourceImagePath) return;
    [arguments addObject:@"-image"]; [arguments addObject:self.sourceImagePath];
    
    [arguments addObject:@"-top"];    [arguments addObject:top];
    [arguments addObject:@"-bottom"]; [arguments addObject:bottom];
    
    NSPipe *pipe = [NSPipe pipe];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"yarly"]];
    [task setArguments:arguments];
    [task setStandardOutput:pipe];
    NSLog(@"launching yarly...");
    [task launch];
    self.macroImageData = [[pipe fileHandleForReading] readDataToEndOfFile];
    [self.macroImageView setImageData:self.macroImageData type:(__bridge NSString *)kUTTypePNG name:fileName];
    [task waitUntilExit];
    NSLog(@"...yarly done");
    if ([task terminationStatus] == 0)
    {
        NSLog(@"yarly succeeded");
    }
    else
    {
        NSLog(@"yarly failed: %d", [task terminationStatus]);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self)
    {
        NSLog(@"keyPath: %@", keyPath);
        [self render];
    }
    else if (object == self.sourceImageView)
    {
        self.sourceImagePath = [self.sourceImageView imagePath];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
    return YES;
}

@end
