#import <MetalKit/MetalKit.h>
#import <Metal/Metal.h>

@interface Renderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

- (nonnull id<MTLRenderCommandEncoder>)getRenderCommandEncoder;

- (void)createCommandBuffer;

- (void)createRenderCommandEncoder:(nonnull MTLRenderPassDescriptor*)renderPassDescriptor;

- (void)createRenderPassDescriptor:(CGSize)drawableSize;

@end
