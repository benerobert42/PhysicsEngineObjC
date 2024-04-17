#include "MetalToCpp.h"

void bindVertexBytes(id<MTLRenderCommandEncoder> renderEncoder,
                     const Eigen::Matrix4f& matrix,
                     int bufferIndex) {
    [renderEncoder setVertexBytes:matrix.data() length:sizeof(Eigen::Matrix4f) atIndex:bufferIndex];
}
