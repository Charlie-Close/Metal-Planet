//
//  definitions.h
//  Graphics
//
//  Created by Charlie Close on 11/06/2023.
//

#ifndef definitions_h
#define definitions_h

#include <simd/simd.h>

struct Vertex {
    vector_float3 position;
    vector_float4 colour;
    vector_float3 normal;
};

struct CameraParameters {
    matrix_float4x4 view;
    matrix_float4x4 projection;
};

#endif /* definitions_h */
