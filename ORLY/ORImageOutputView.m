#import "ORImageOutputView.h"

@interface ORImageOutputView ()

@property (strong) NSData *data;
@property (strong) NSString *type;
@property (strong) NSString *name;

@end

@implementation ORImageOutputView

@synthesize data = _data;
@synthesize type = _type;
@synthesize name = _name;

+ (NSSet *)keyPathsForValuesAffectingImageData
{
    return [NSSet setWithObjects:@"image", nil];
}

- (void)setImage:(NSImage*)image
{
	abort();
}

- (void)setImageData:(NSData *)imageData type:(NSString *)type name:(NSString *)name
{
    self.data = imageData;
    self.type = type;
    self.name = name;
    [super setImage:[[NSImage alloc] initWithData:imageData]];
}

- (void)mouseDown:(NSEvent *)event
{
    if (self.data)
    {
        NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
        [pasteboard declareTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType, self.type, nil] owner:self];
        [pasteboard setPropertyList:[NSArray arrayWithObjects:self.type, nil] forType:NSFilesPromisePboardType];
        [pasteboard setData:self.data forType:self.type];
        
        NSSize size = [[self image] size];
        NSPoint location = NSMakePoint(
            ([self bounds].size.width - size.width)/2,
            ([self bounds].size.height - size.height)/2);
        [self dragImage:self.image at:location offset:NSZeroSize event:event pasteboard:pasteboard source:self slideBack:YES];
    }
}

- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{
    NSString *fileName = [self.name stringByAppendingPathExtension:(__bridge NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)self.type, kUTTagClassFilenameExtension)];
    [self.data writeToFile:[[dropDestination relativePath] stringByAppendingPathComponent:fileName] options:0 error:nil];
    return [NSArray arrayWithObject:fileName];
}

@end
