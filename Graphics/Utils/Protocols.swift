//
//  Noise.swift
//  Graphics
//
//  Created by Charlie Close on 13/06/2023.
//

import Foundation
import GameKit

protocol NoiseProtocol {
    func value(pos: simd_double3) -> Double
    func Colour(pos: simd_double3, norm: simd_float3) -> simd_float4
    func getNormal(pos: simd_double3) -> simd_float3
}

protocol PlanetProtocol {
    var Position: simd_float3 { get set }
    
    func drawMesh(cameraView: matrix_float4x4, view: MTKView, renderEncoder: MTLRenderCommandEncoder, metalDevice: MTLDevice, position: simd_float3) -> Void
}
