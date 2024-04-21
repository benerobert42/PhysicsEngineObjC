#include <simd/simd.h>

#import "Renderer.h"
#import "ShaderTypes.h"
#include "Engine.h"
#include "RigidBody.h"

#include "Eigen/Dense"

@implementation Renderer
{
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLCommandQueue> _commandQueue;
    vector_double2 _viewportSize;

    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _indexBuffer;
    id<MTLBuffer> _instanceBuffer;
    id<MTLCommandBuffer> _commandBuffer;
    MTLRenderPassDescriptor *_renderPassDescriptor;
    id<MTLRenderCommandEncoder> _renderEncoder;
    PhysicsEngine _engine;
    
    NSTimeInterval _lastDrawTime;
    NSTimeInterval _frameDuration; // Desired frame duration in seconds (e.g., 1.0 / 60 for 60 fps)
}

- (id<MTLRenderCommandEncoder>)getRenderCommandEncoder
{
    return _renderEncoder;
}

- (void)createInstancesBuffer:(int)objectCount
{
    _instanceBuffer = [_device newBufferWithLength: sizeof(float) * 16 * objectCount options:MTLResourceStorageModeShared];
}

- (void)createMetalBuffersForSphereWithRadius:(float)radius
{
    MTKMeshBufferAllocator *allocator = [[MTKMeshBufferAllocator alloc] initWithDevice:_device];
    
    MDLMesh *sphereMDLMesh = [[MDLMesh alloc] initSphereWithExtent:(vector_float3){radius, radius, radius}
                                                          segments:(vector_uint2){64, 64}
                                                     inwardNormals:NO
                                                      geometryType:MDLGeometryTypeTriangles
                                                         allocator:allocator];

    NSError *error;
    MTKMesh *metalKitMesh = [[MTKMesh alloc] initWithMesh:sphereMDLMesh device:_device error:&error];

    if (error != nil) {
        NSLog(@"Error creating MTKMesh: %@", (error).localizedDescription);
    }

    _vertexBuffer = metalKitMesh.vertexBuffers[0].buffer;

    MTKSubmesh *submesh = metalKitMesh.submeshes[0];
    _indexBuffer = submesh.indexBuffer.buffer;
}

- (void)createCommandBuffer
{
    _commandBuffer = [_commandQueue commandBuffer];
}

- (void)createRenderPassDescriptor:(CGSize)size
{
    // Configure color attachment
    MTLTextureDescriptor *colorTextureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:size.width height:size.height mipmapped:NO];
    colorTextureDescriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    id<MTLTexture> colorTexture = [_device newTextureWithDescriptor:colorTextureDescriptor];

    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];

    MTLRenderPassColorAttachmentDescriptor *colorAttachment = renderPassDescriptor.colorAttachments[0];
    colorAttachment.texture = colorTexture;
    colorAttachment.loadAction = MTLLoadActionClear;
    colorAttachment.clearColor = MTLClearColorMake(0.0, 0.4, 0.6, 1.0);
    colorAttachment.storeAction = MTLStoreActionStore;

    // Configure depth attachment
    MTLRenderPassDepthAttachmentDescriptor *depthAttachment = renderPassDescriptor.depthAttachment;
    if (depthAttachment) {
        MTLTextureDescriptor *depthTextureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:size.width height:size.height mipmapped:NO];
        depthTextureDescriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
        depthTextureDescriptor.storageMode = MTLStorageModePrivate;
        
        id<MTLTexture> depthTexture = [_device newTextureWithDescriptor:depthTextureDescriptor];
        depthAttachment.texture = depthTexture;
        depthAttachment.loadAction = MTLLoadActionClear;
        depthAttachment.storeAction = MTLStoreActionDontCare;
    }
    
    _renderPassDescriptor = renderPassDescriptor;
}

- (void)createRenderCommandEncoder: (MTLRenderPassDescriptor*)renderPassDescriptor
{
    _renderEncoder = [self->_commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    _renderEncoder.label = @"MyRenderEncoder";
}


- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        NSError *error;

        _device = mtkView.device;
        
        _frameDuration = 1.0 / 60.0; // Default frame duration for 60 fps
        _lastDrawTime = 0.0;

        // Load all the shader files with a .metal file extension in the project.
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertex_main"];
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragment_main"];

        // Configure a pipeline descriptor that is used to create a pipeline state.
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Simple Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;

        // Create Metal buffers for vertex and index data
        [self createMetalBuffersForSphereWithRadius:0.1];

        // Set the vertex descriptor
        pipelineStateDescriptor.vertexDescriptor = [[MTLVertexDescriptor alloc] init];

        // Configure Metal vertex descriptor based on MDLVertexDescriptor
        MTLVertexDescriptor *mtlVertexDescriptor = pipelineStateDescriptor.vertexDescriptor;

        // Position attribute
        mtlVertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
        mtlVertexDescriptor.attributes[0].offset = 0;
        mtlVertexDescriptor.attributes[0].bufferIndex = 0;

        // Normal attribute
        mtlVertexDescriptor.attributes[1].format = MTLVertexFormatFloat3;
        mtlVertexDescriptor.attributes[1].offset = sizeof(float) * 3;
        mtlVertexDescriptor.attributes[1].bufferIndex = 0;

        // Texture coordinate attribute
        mtlVertexDescriptor.attributes[2].format = MTLVertexFormatFloat2;
        mtlVertexDescriptor.attributes[2].offset = sizeof(float) * 6;
        mtlVertexDescriptor.attributes[2].bufferIndex = 0;

        // Position buffer layout
        mtlVertexDescriptor.layouts[0].stride = sizeof(float) * 8;
        mtlVertexDescriptor.layouts[0].stepRate = 1;
        mtlVertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
        
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                 error:&error];
        NSAssert(_pipelineState, @"Failed to create pipeline state: %@", error);

        // Create the command queue
        _commandQueue = [_device newCommandQueue];
        
        RigidBody body_1;
        Vector3f position_2 {0, 0, 0.5};
        Vector3f velocity_2 {0.5, 0.5, 0};
        RigidBody body_2 {position_2, velocity_2};
        _engine.addBody(&body_1);
        _engine.addBody(&body_2);
    }

    return self;
}

/// Called whenever view changes orientation or is resized
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // Save the size of the drawable to pass to the vertex shader.
    _viewportSize.x = size.width;
    _viewportSize.y = size.width;
}

/// Called whenever the view needs to render a frame.
- (void)drawInMTKView:(nonnull MTKView *)view
{
    NSTimeInterval currentTime = CACurrentMediaTime();
    NSTimeInterval elapsedTime = currentTime - _lastDrawTime;

    if (elapsedTime >= _frameDuration) {
        _lastDrawTime = currentTime;
        _engine.update();
        // Obtain a renderPassDescriptor generated from the view's drawable textures.
        //[self createRenderPassDescriptor:view.drawableSize];
        
        _renderPassDescriptor = view.currentRenderPassDescriptor;

        id<MTLDrawable> drawable = view.currentDrawable;
           
        id<MTLCommandBuffer> _commandBuffer = [self->_commandQueue commandBuffer];
        id<MTLRenderCommandEncoder> _renderEncoder = [_commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
        _renderEncoder.label = @"MyRenderEncoder";
               
        if(_renderPassDescriptor != nil)
        {
            //[self createCommandBuffer];
            //[self createRenderCommandEncoder:view.currentRenderPassDescriptor];

            // Set the region of the drawable to draw into.
            [_renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, 0.0, 1.0 }];

            [_renderEncoder setRenderPipelineState:_pipelineState];

            // Pass in the parameter data.
            [self createInstancesBuffer:2];

            [_renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:vertexBufferIndex];
            [_renderEncoder setVertexBuffer:_indexBuffer offset:0 atIndex:indexBufferIndex];
            [_renderEncoder setVertexBuffer:_instanceBuffer offset:0 atIndex:instanceBufferIndex];
            
            [_renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:viewportSizeIndex];
            
            for (int i = 0; i < _engine._bodies.size(); i++) {
                auto matrix = _engine._bodies[i]->_modelTransform;
                
                [_renderEncoder setVertexBytes:matrix.matrix().data() length:sizeof(float) * 16 atIndex:instanceBufferIndex];
                
                [_renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                          indexCount:_indexBuffer.length / sizeof(uint16_t)
                                           indexType:MTLIndexTypeUInt16
                                         indexBuffer:_indexBuffer
                                   indexBufferOffset:0
                                       instanceCount:1];
            }
                        

            [_commandBuffer presentDrawable:view.currentDrawable];
            
            [_renderEncoder endEncoding];
            [_commandBuffer commit];
        }
    }
}

@end

