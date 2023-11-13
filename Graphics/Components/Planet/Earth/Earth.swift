//
//  Earth.swift
//  Graphics
//
//  Created by Charlie Close on 25/06/2023.
//

import MetalKit

class Earth: PlanetProtocol {
    var Triangles: [SubDivTriangle]
    var Position: simd_float3
    var Mesh: Mesh
    var Water: Mesh
    var Noise: NoiseProtocol
    let waterNoise: NoiseProtocol
    var Updating: Bool = false
    let Radius: Float = 1
    let renderer: MeshRenderer;
    
    init(metalDevice: MTLDevice, position: simd_float3) {
        Noise = EarthNoise()
        waterNoise = constNoise(radius: Radius, colour: [0, 0.2, 0.6, 1])
        
        let InitialTriangles = tri_sphere(Noise: Noise)
        let waterTriangles = tri_sphere(Noise: waterNoise)
        
        for i in InitialTriangles {
            i.SubDivide(center: position, noise: Noise, subDivs: 4)
        }
        
        Triangles = []
        for i in InitialTriangles {
            for j in getSubTriangles(tri: i) {
                Triangles.append(j)
            }
        }
        
        for i in waterTriangles {
            i.DetailTriangle(detail: 9, noise: waterNoise)
        }
        
        Water = collectMesh(metalDevice: metalDevice, tris: waterTriangles)
        
        Position = position
        self.Mesh = collectMesh(metalDevice: metalDevice, tris: Triangles)
        
        renderer = MeshRenderer(vertexShader: "planetShader", fragmentShader: "fragmentShader")
    }
    
    func reMesh(metalDevice: MTLDevice, pos: simd_float3) async {
        for i in Triangles {
            let normCenter = normalize(i.Center)
            let dist = length(i.Center + Position - pos)
            let angle = dot(normalize(pos - Position - (normCenter * Radius)), normCenter)

            if angle > 0.2 {
                if dist > 5 {
                    i.DetailTriangle(detail: 2, noise: Noise)
                } else if dist > 3 {
                    i.DetailTriangle(detail: 6, noise: Noise)
                } else if dist > 2 {
                    i.DetailTriangle(detail: 10, noise: Noise)
                } else {
                    i.DetailTriangle(detail: 20, noise: Noise)
                }
            } else {
                i.Reset(center: Position)
            }
        }
        self.Mesh = collectMesh(metalDevice: metalDevice, tris: Triangles)
        Updating = false
    }
    
    func drawMesh(cameraView: matrix_float4x4, view: MTKView, renderEncoder: MTLRenderCommandEncoder, metalDevice: MTLDevice, position: simd_float3) {
        let posPar = parameter(pointer: &Position, length: MemoryLayout<simd_float3>.size)
        
        let dist = abs(length(position - Position))
        renderer.drawMeshes(meshes: [Mesh, Water], near: max(dist - 2, 0.1), far: dist + 2, cameraView: cameraView, view: view, renderEncoder: renderEncoder, parameters: [posPar])
        if (!Updating) {
            Updating = true
            Task {
                await reMesh(metalDevice: metalDevice, pos: position)
            }
        }
    }
}
