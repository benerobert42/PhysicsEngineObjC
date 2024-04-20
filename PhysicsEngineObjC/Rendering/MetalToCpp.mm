#include "MetalToCpp.h"

#include "Renderer.h"
#include "ViewController.h"

void bindVertexBytes(const Eigen::Matrix4f& matrix,
                     int bufferIndex) {
    [_renderer.renderEncoder setVertexBytes:matrix.data() length:sizeof(Eigen::Matrix4f) atIndex:bufferIndex];
}
