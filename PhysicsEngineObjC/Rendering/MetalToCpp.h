#pragma once

#include <Metal/Metal.h>

#include "Eigen/Dense"

#include "Renderer.h"

#include "ViewController.h"

#import <Cocoa/Cocoa.h>

Renderer* getRenderer();

id<MTLRenderCommandEncoder> getRenderCommandEncoder();
    
void bindVertexBytes(id<MTLRenderCommandEncoder> renderEncoder,
                     const Eigen::Affine3f& matrix,
                     int bufferIndex);

void setupRenderer();
