#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef enum BufferIndex
{
    vertexBufferIndex = 0,
    indexBufferIndex = 1,
    instanceBufferIndex =2,
    viewProjectionMatrixIndex = 12,
    viewportSizeIndex = 13,
} BufferIndex;

typedef struct
{
    matrix_float4x4 modelMatrix;
    //matrix_float3x3 normalMatrix;
} modelTransform;

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
} perFrameConstants;

#endif /* ShaderTypes_h */

