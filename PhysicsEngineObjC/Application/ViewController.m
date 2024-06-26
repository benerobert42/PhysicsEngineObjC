#import "ViewController.h"
#import "Renderer.h"

@implementation ViewController
{
    MTKView *_view;
    Renderer *_renderer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the view to use the default device
    _view = (MTKView *)self.view;
    _view.device = MTLCreateSystemDefaultDevice();
    //_view.clearColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0);
    
    NSAssert(_view.device, @"Metal is not supported on this device");
    _renderer = [[Renderer alloc] initWithMetalKitView:_view];
    NSAssert(_renderer, @"Renderer failed initialization");
    // Initialize our renderer with the view size
    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];

    _view.delegate = _renderer;
}

- (Renderer *)getRenderer {
    return _renderer;
}

@end
