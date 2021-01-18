//
//  RZMView.m
//  rzpaas_example_mac
//
//  Created by yxibng on 2020/11/22.
//

#import "RZMView.h"

@implementation RZMView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.wantsLayer = YES;
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.wantsLayer = YES;
    }
    return self;
}


- (BOOL)wantsUpdateLayer {
    return YES;
}

- (void)updateLayer {
    if (!_backgroundColor) {
        return;
    }
    
    if (!self.layer) {
        return;
    }
    
    self.layer.backgroundColor = self.backgroundColor.CGColor;

}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    if (self.disableEvents) {
        return NO;
    }
    return YES;
}

- (NSView *)hitTest:(NSPoint)aPoint {
    if (self.disableEvents) {
        return nil;
    }
    return [super hitTest:aPoint];
}

- (void)mouseDown:(NSEvent *)event {
    if (!self.isMaskView) {
        [super mouseDown:event];
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    if (!self.isMaskView) {
        [super rightMouseDown:event];
    }
}


@end
