//
//  planetMesh.swift
//  Graphics
//
//  Created by Charlie Close on 13/06/2023.
//

import MetalKit

struct VandI {
    var Vertices: [Vertex]
    var Indices: [UInt32]
}

class Mesh {
    var VertexBuffer: MTLBuffer
    var IndexBuffer: MTLBuffer
    var Length: Int
    
    init(metalDevice: MTLDevice, vAndI: VandI) {
        VertexBuffer = metalDevice.makeBuffer(bytes: vAndI.Vertices, length: vAndI.Vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        IndexBuffer = metalDevice.makeBuffer(bytes: vAndI.Indices, length: vAndI.Indices.count * MemoryLayout<UInt32>.stride, options: [])!
        Length = vAndI.Indices.count
    }
    
}

func collectVerts(tris: [SubDivTriangle]) -> VandI {
    var Vertices: [Vertex] = []
    var Indices: [UInt32] = []
    
    var count: UInt32 = 0
    for tri in tris {
        for ind in tri.Indices {
            Indices.append(ind + count)
        }
        for vert in tri.Vertices {
            Vertices.append(vert)
        }
        count += UInt32(tri.Vertices.count)
    }
    return VandI(Vertices: Vertices, Indices: Indices)
}

func collectMesh(metalDevice: MTLDevice, tris: [SubDivTriangle]) -> Mesh {
    return Mesh(metalDevice: metalDevice, vAndI: collectVerts(tris: tris))
}
