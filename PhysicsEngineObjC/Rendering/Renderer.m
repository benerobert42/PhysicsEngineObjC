@import simd;
@import MetalKit;

#import "Renderer.h"
#import "ShaderTypes.h"

@implementation Renderer
{
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLCommandQueue> _commandQueue;
    vector_uint2 _viewportSize;

    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _indexBuffer;
    id<MTLBuffer> _instanceBuffer;
    
    NSTimeInterval _lastDrawTime;
    NSTimeInterval _frameDuration; // Desired frame duration in seconds (e.g., 1.0 / 60 for 60 fps)

}

- (NSMutableArray<NSData *> *)createModelMatrices {
    // Number of instances
    NSUInteger numInstances = 5;

    // Initialize an array to hold the model matrices
    NSMutableArray<NSData *> *modelMatrices = [NSMutableArray arrayWithCapacity:numInstances];

    // Define the translation amounts along y and x axis
    float yTranslation = 0.2; // Change this according to your desired y-axis translation
    float xTranslationIncrement = 0.2; // Change this according to your desired x-axis translation increment

    // Create model matrices for each instance
    for (NSUInteger i = 0; i < numInstances; i++) {
        // Calculate x translation based on instance index
        float xTranslation = i * xTranslationIncrement;

        // Create a translation matrix using simd library
        matrix_float4x4 translationMatrix = matrix_identity_float4x4;
        translationMatrix.columns[3].x = xTranslation;
        translationMatrix.columns[3].y = yTranslation;

        // Convert the matrix to NSData
        NSData *matrixData = [NSData dataWithBytes:&translationMatrix length:sizeof(matrix_float4x4)];

        // Add the matrix data to the array
        [modelMatrices addObject:matrixData];
    }
    return modelMatrices;
}



- (id<MTLBuffer>)createInstancesBuffer:(int)objectCount
{
    id<MTLBuffer> instancesBuffer = [_device newBufferWithLength: sizeof(float) * (16 + 9) * objectCount options:MTLResourceStorageModeShared];
    
    return instancesBuffer;
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


- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        NSError *error;

        _device = mtkView.device;
        
        _frameDuration = 1.0 / 60.0; // Default frame duration for 60 fps

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
        
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
        commandBuffer.label = @"MyCommand";
        
        // Obtain a renderPassDescriptor generated from the view's drawable textures.
        MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
        
        if(renderPassDescriptor != nil)
        {
            // Create a render command encoder.
            id<MTLRenderCommandEncoder> renderEncoder =
            [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            renderEncoder.label = @"MyRenderEncoder";
            
            // Set the region of the drawable to draw into.
            [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, 0.0, 1.0 }];
            
            [renderEncoder setRenderPipelineState:_pipelineState];
            
            // Pass in the parameter data.
            [self createInstancesBuffer:5];
            
            [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:vertexBufferIndex];
            [renderEncoder setVertexBuffer:_instanceBuffer offset:0 atIndex:indexBufferIndex];
            [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:viewportSizeIndex];
            
            NSArray<NSData *> *modelMatrices = [self createModelMatrices];
            
            for (int i = 0; i < modelMatrices.count; i++) {
                NSData *matrixData = modelMatrices[i];
                matrix_float4x4 modelMatrix;
                [matrixData getBytes:&modelMatrix length:sizeof(matrix_float4x4)];
                
                [renderEncoder setVertexBytes:&modelMatrix length:sizeof(matrix_float4x4) atIndex:instanceBufferIndex];
                
                [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                          indexCount:_indexBuffer.length / sizeof(uint16_t)
                                           indexType:MTLIndexTypeUInt16
                                         indexBuffer:_indexBuffer
                                   indexBufferOffset:0
                                       instanceCount:1];
            }
            
            
            [renderEncoder endEncoding];
            
            // Schedule a present once the framebuffer is complete using the current drawable.
            [commandBuffer presentDrawable:view.currentDrawable];
        }
        
        // Finalize rendering here & push the command buffer to the GPU.
        [commandBuffer commit];
    }
}

@end

