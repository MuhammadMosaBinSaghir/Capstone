#include <metal_stdlib>
#import "uniforms.h"
using namespace metal;

vertex float4 vertexed(float4 coordinates [[attribute(0)]] [[stage_in]], constant Uniforms &uniforms [[buffer(1)]]) {
    float4 position = uniforms.projection * uniforms.view * uniforms.model * coordinates;
    return position;
}

fragment float4 fragmented() { return float4(1, 1, 1, 1); }
