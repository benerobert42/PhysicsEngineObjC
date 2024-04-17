#pragma once

#include <Metal/Metal.h>

#include "Eigen/Dense"

void bindVertexBytes(id<MTLRenderCommandEncoder> renderEncoder,
                     const Eigen::Matrix4f& matrix,
                     int bufferIndex);
