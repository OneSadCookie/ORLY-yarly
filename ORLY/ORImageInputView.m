// based loosely on
// PRImageView.m
// Created by Gregory Weston on 3/5/08.
// from http://www.cocoadev.com/index.pl?NSImageView

#import "ORImageInputView.h"

@implementation ORImageInputView

+ (NSSet *)keyPathsForValuesAffectingImagePath
{
    return [NSSet setWithObjects:@"image", nil];
}

@synthesize imagePath = _imagePath;

- (void)setImage:(NSImage*)image
{
	_imagePath = nil;
    [super setImage:image];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    [super concludeDragOperation:sender];
        
    NSURL *url = [[[sender draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]] options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSPasteboardURLReadingFileURLsOnlyKey, nil]] objectAtIndex:0];
    // NSLog(@"dropped: %@", url);
    self.imagePath = [url path];
}

- (void)setImagePath:(NSString *)path
{
    _imagePath = path;
    [super setImage:[[NSImage alloc] initWithContentsOfFile:path]];
}

@end
