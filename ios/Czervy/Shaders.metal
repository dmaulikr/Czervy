//
//  Shaders.metal
//  Czervy
//
//  Created by master on 8/13/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Create a basic vertex
vertex float4 basic_vertex(
   const device packed_float3* vertex_array [[ buffer(0) ]],
   unsigned int vid [[ vertex_id ]])
{
    return float4(vertex_array[vid], 1.0);
}

// Create a basic fragment
fragment half4 basic_fragment() {
  return half4(1.0);             
}