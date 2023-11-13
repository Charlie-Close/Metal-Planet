//
//  camera.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//
import Foundation

class Camera {
    
    var position: vector_float3
    var eulers: vector_float3
    
    var forwards: vector_float3
    var right: vector_float3
    var up: vector_float3
    var x: vector_float3
    var y: vector_float3
    var vert: CGFloat
    
    var drag: CGSize
        
    init(position: vector_float3, eulers: vector_float3) {
        
        self.position = position
        self.eulers = eulers
        
        self.forwards = [0.0, 0.0, 0.0]
        self.right = [0.0, 0.0, 0.0]
        self.up = [0.0, 0.0, 1.0]
        self.drag = CGSize(width: 0, height: 0)
        self.x = [1, 0, 0]
        self.y = [0, 1, 0]
        self.vert = 0
    }
    
    func updateVectors() {
        
        let eF: [Float] = [
            cos(eulers[2] * .pi / 180.0) * sin(eulers[1] * .pi / 180.0),
            sin(eulers[2] * .pi / 180.0) * sin(eulers[1] * .pi / 180.0),
            cos(eulers[1] * .pi / 180.0)
        ]
                
        forwards = x * eF[0] + y * eF[1] + up * eF[2]
        right = normalize(cross(up, forwards))
                
//        right = (y * cos(eulers[2] * .pi / 180.0) * sin(eulers[1] * .pi / 180.0)) +
//        (-x * sin(eulers[2] * .pi / 180.0) * sin(eulers[1] * .pi / 180.0))
        
//        up = [0, 0, 1]//simd.normalize(simd.cross(forwards, right))
        
        position -= Float(drag.height) * 0.001 * forwards
        position += Float(drag.width) * 0.001 * right
        position += Float(vert) * 0.001 * up
    }
    
    func rotateUp(up: simd_float3) {
        self.up = up
        if up == [0, 0, 1] {
            x = [1, 0, 0]
        } else {
            x = simd.normalize(simd.cross(up, [0, 0, 1]))
        }
        y = simd.normalize(simd.cross(up, x))
    }
}
