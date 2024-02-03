#include <metal_stdlib>
using namespace metal;

vertex float4 vertexed(float4 position [[attribute(0)]] [[stage_in]]) {
    return position;
}

fragment float4 fragmented() { return float4(1, 1, 1, 1); }
