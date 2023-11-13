//
//  Earth.swift
//  Graphics
//
//  Created by Charlie Close on 25/06/2023.
//

import MetalKit

class Moon: PlanetProtocol {
    var Triangles: [SubDivTriangle]
    var Position: simd_float3
    var Mesh: Mesh
    var Noise: NoiseProtocol
    var Updating: Bool = false
    let Radius: Float = 0.5
    let renderer: MeshRenderer;
    var Detailed: Bool = false;
    
    init(metalDevice: MTLDevice, position: simd_float3) {
        Noise = MoonNoise()
        
        let InitialTriangles = tri_sphere(Noise: Noise)
        for i in InitialTriangles {
            i.SubDivide(center: position, noise: Noise, subDivs: 4)
        }
        
        Triangles = []
        for i in InitialTriangles {
            for j in getSubTriangles(tri: i) {
                Triangles.append(j)
            }
        }
                
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
        Detailed = true
    }
    
    func deMesh(metalDevice: MTLDevice, pos: simd_float3) async {
        for i in Triangles {
            i.DetailTriangle(detail: 1, noise: Noise)
        }
        Detailed = false
    }
    
    func updateUpdating() async {
        do {
            try await Task.sleep(nanoseconds: UInt64(2 * Double(1000)))
            Updating = false
        } catch {}
    }
    
    func drawMesh(cameraView: matrix_float4x4, view: MTKView, renderEncoder: MTLRenderCommandEncoder, metalDevice: MTLDevice, position: simd_float3) {
        let posPar = parameter(pointer: &Position, length: MemoryLayout<simd_float3>.size)
        
        let dist = abs(length(position - Position))
        renderer.drawMeshes(meshes: [Mesh], near: max(dist - 2, 0.1), far: dist + 2, cameraView: cameraView, view: view, renderEncoder: renderEncoder, parameters: [posPar])
        if (!Updating) {
            Updating = true
            Task {
                if (dist > 10 && Detailed) {
                    await deMesh(metalDevice: metalDevice, pos: position)
                } else {
                    await reMesh(metalDevice: metalDevice, pos: position)
                }
                await updateUpdating()
            }
        }
    }
}
