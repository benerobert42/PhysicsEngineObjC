#include "ShaderTypes.h"

#include <metal_stdlib>

using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float4 color [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float4 color;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]],
                             constant matrix_float4x4 &modelTransform [[buffer(instanceBufferIndex)]])
{
    VertexOut out {
        .position = modelTransform * in.position,
        .normal = in.normal,
        .color = in.color
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]])
{
    float3 baseColor = 0.6*(dot(in.normal, float3(1,1,1))) * float3(0,0.8,0.6) + float3(0,0.8,0.6) * 0.7;
    return float4(baseColor, 1.0);
}



