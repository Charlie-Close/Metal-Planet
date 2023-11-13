//
//   Shaders.metal
//  Graphics
//
//  Created by Charlie Close on 11/06/2023.
//

#include <metal_stdlib>
using namespace metal;

#include "../definitions.h"

struct Fragment {
    float4 position [[position]];
    float4 color;
};

vertex Fragment vertexShader(
        const device Vertex *vertexArray[[buffer(0)]],
        unsigned int vid [[vertex_id]],
        constant matrix_float4x4 &cameraMatrix [[ buffer(1) ]]
    ) {
        Vertex input = vertexArray[vid];
        
        Fragment output;
        output.position = cameraMatrix * float4(input.position.x, input.position.y, input.position.z, 1);
        output.color = (input.normal[1] + 1) / 2 * input.colour;
        
        return output;
}

fragment float4 fragmentShader(Fragment input [[stage_in]]) {
    return input.color;
}

vertex Fragment planetShader(
        const device Vertex *vertexArray[[buffer(0)]],
        unsigned int vid [[vertex_id]],
        constant matrix_float4x4 &cameraMatrix [[ buffer(1) ]],
        constant float3 &position [[ buffer(2) ]]
    ) {
        Vertex input = vertexArray[vid];

        Fragment output;
        output.position = cameraMatrix * float4(input.position.x + position.x, input.position.y  + position.y, input.position.z + position.z, 1);
        output.color = (input.normal[1] + 1) / 2 * input.colour;

        return output;
}
