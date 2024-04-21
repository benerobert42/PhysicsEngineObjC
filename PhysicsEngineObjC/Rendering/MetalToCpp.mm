#include "MetalToCpp.h"

Renderer* getRenderer() {
    NSStoryboard *mainStoryboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSViewController *initialViewController = [mainStoryboard instantiateInitialController];
    // Assuming the initial view controller is of type ViewController
    if ([initialViewController isKindOfClass:[ViewController class]]) {
        ViewController *viewController = (ViewController *)initialViewController;
        return viewController.getRenderer ;
    } else {
        return nil; // Handle case where initial view controller is not of expected type
    }
}

id<MTLRenderCommandEncoder> getRenderCommandEncoder() {
    Renderer* renderer = getRenderer();
    id<MTLRenderCommandEncoder> renderEncoder = [renderer getRenderCommandEncoder];
    return renderEncoder;
}

void bindVertexBytes(id<MTLRenderCommandEncoder> renderEncoder,
                     const Eigen::Affine3f& matrix,
                     int bufferIndex) {
    [renderEncoder setVertexBytes:matrix.matrix().data() length:sizeof(float) * 16 atIndex:bufferIndex];
}

void setupRenderer() {
    MTKView* view = [[MTKView alloc] initWithFrame:CGRectZero];
    view.device = MTLCreateSystemDefaultDevice();
    if (view.device) {
        Renderer* renderer = [[Renderer alloc] initWithMetalKitView:view];
        [renderer createCommandBuffer];
        [renderer createRenderCommandEncoder:view.currentRenderPassDescriptor];
    } else {
        NSLog(@"Metal is not supported on this device.");
    }
}
