//
//  ConstantNoise.swift
//  Graphics
//
//  Created by Charlie Close on 25/06/2023.
//

class constNoise: NoiseProtocol {
    var Radius: Float
    var ConstColour: simd_float4
    
    init(radius: Float, colour: simd_float4) {
        Radius = radius
        ConstColour = colour
    }
    
    func value(pos: simd_double3) -> Double {
        return Double(Radius)
    }
    
    func getNormal(pos: simd_double3) -> simd_float3 {
        return normalize(simd_float3(pos))
    }
    
    func Colour(pos: simd_double3, norm: simd_float3) -> simd_float4 {
        return ConstColour
    }
}
