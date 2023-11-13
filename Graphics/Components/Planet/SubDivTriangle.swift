//
//  SubDivTriangle.swift
//  Graphics
//
//  Created by Charlie Close on 13/06/2023.
//

import GameKit

func getNV(noise: GKNoise, pos: simd_float3) -> Float {
    let DoublePos: vector_double3 = [Double(pos[0]), Double(pos[1]), Double(pos[2])]
    noise.move(by: DoublePos)
    let val = noise.value(atPosition: [0, 0])
    noise.move(by: -DoublePos)
//    print(val)
    return val + 1
}

func CreateVertex(position: simd_float3, noise: NoiseProtocol) -> Vertex {
    let truePos = normalize(position)
    let doublePos = simd_double3(truePos)
    let norm = noise.getNormal(pos: doublePos)
    return Vertex(position: truePos * Float(noise.value(pos: doublePos)), colour: noise.Colour(pos: doublePos, norm: norm), normal: norm)
}

class SubDivTriangle {
    var Corners: [simd_float3]
    var OriginalVertices: [Vertex]
    var OriginalIndices: [UInt32]
    var Vertices: [Vertex]
    var Indices: [UInt32]
    var Center: simd_float3
    var SubTriangles: [SubDivTriangle]
    var Detail: Int = 1
    
    init(center: simd_float3, corners: [simd_float3], noise: NoiseProtocol) {
        Corners = corners
        Vertices = [
            CreateVertex(position: Corners[0], noise: noise),
            CreateVertex(position: Corners[1], noise: noise),
            CreateVertex(position: Corners[2], noise: noise),
        ]
        
        Center = (Vertices[0].position + Vertices[1].position + Vertices[2].position) / 3
        
        Indices = [
            0, 1, 2
        ]
        
        OriginalVertices = [Vertices[0], Vertices[1], Vertices[2]]
        OriginalIndices = [0, 1, 2]
        
        SubTriangles = []
    }
    
    func SubDivide(center: simd_float3, noise: NoiseProtocol, subDivs: Int = 4) {
        let NCS: [simd_float3] = [
                                                Corners[0],
                    (Corners[0] + Corners[1]) / 2,       (Corners[0] + Corners[2]) / 2,
            Corners[1],                 (Corners[1] + Corners[2]) / 2,              Corners[2]
        ]
        
        SubTriangles = [
            SubDivTriangle(center: center, corners: [NCS[0], NCS[1], NCS[2]], noise: noise),
            SubDivTriangle(center: center, corners: [NCS[1], NCS[3], NCS[4]], noise: noise),
            SubDivTriangle(center: center, corners: [NCS[1], NCS[2], NCS[4]], noise: noise),
            SubDivTriangle(center: center, corners: [NCS[2], NCS[4], NCS[5]], noise: noise)
            ]
        
        if subDivs > 1 {
            for i in SubTriangles {
                i.SubDivide(center: center, noise: noise, subDivs: subDivs - 1)
            }
        }
        
        let VertData = collectVerts(tris: SubTriangles)
        Vertices = VertData.Vertices
        Indices = VertData.Indices
    }
    
    func DetailTriangle(detail: Int, noise: NoiseProtocol) {
        if detail > Detail {
            Vertices = [CreateVertex(position: Corners[0], noise: noise)]
            Indices = []
            var PreviousCorners = [Corners[0]]
            var NewCorners: [simd_float3] = []
            let leftVect: simd_float3 = (Corners[1] - Corners[0]) / Float(detail)
            let rightVect: simd_float3 = (Corners[2] - Corners[0]) / Float(detail)
            
            for i in 0...(detail - 1) {
                let a = UInt32(Vertices.count - PreviousCorners.count)
                let b = UInt32(i + 1)
                Indices.append(a)
                Indices.append(a + b)
                Indices.append(a + b + 1)
                if i != 0 {
                    for j in 0...(i - 1) {
                        let c = a + UInt32(j + 1)
                        Indices.append(c - 1)
                        Indices.append(c)
                        Indices.append(c + b)
                        
                        Indices.append(c)
                        Indices.append(c + b)
                        Indices.append(c + b + 1)
                    }
                }
                
                
                let first = PreviousCorners[0] + leftVect
                NewCorners = [first]
                Vertices.append(CreateVertex(position: first, noise: noise))
                for j in PreviousCorners {
                    let new = j + rightVect
                    NewCorners.append(new)
                    Vertices.append(CreateVertex(position: new, noise: noise))
                }
                PreviousCorners = NewCorners
            }
        }
    }
    
    func Reset(center: simd_float3) {
        Vertices = OriginalVertices
        
        Indices = OriginalIndices
    }
}

let GRatio: Float = (1 + sqrt(5)) / 2
let NormOne: Float = 1

func tri_sphere(Noise: NoiseProtocol) -> [SubDivTriangle] {
    let position: simd_float3 = [0, 0, 0]
    return [
        SubDivTriangle(center: position, corners: [[0, GRatio, NormOne], [-NormOne, 0, GRatio], [NormOne, 0, GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, GRatio, NormOne], [GRatio, NormOne, 0], [NormOne, 0, GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, GRatio, NormOne], [GRatio, NormOne, 0], [0, GRatio, -NormOne]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, GRatio, NormOne], [-GRatio, NormOne, 0], [0, GRatio, -NormOne]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, GRatio, NormOne], [-GRatio, NormOne, 0], [-NormOne, 0, GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, -GRatio, NormOne], [-NormOne, 0, GRatio], [NormOne, 0, GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, -GRatio, NormOne], [GRatio, -NormOne, 0], [NormOne, 0, GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[GRatio, NormOne, 0], [GRatio, -NormOne, 0], [NormOne, 0, GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[GRatio, NormOne, 0], [GRatio, -NormOne, 0], [NormOne, 0, -GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[GRatio, NormOne, 0], [0, GRatio, -NormOne], [NormOne, 0, -GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[-NormOne, 0, -GRatio], [0, GRatio, -NormOne], [NormOne, 0, -GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[-NormOne, 0, -GRatio], [0, GRatio, -NormOne], [-GRatio, NormOne, 0]], noise: Noise),
        SubDivTriangle(center: position, corners: [[-NormOne, 0, -GRatio], [-GRatio, -NormOne, 0], [-GRatio, NormOne, 0]], noise: Noise),
        SubDivTriangle(center: position, corners: [[-NormOne, 0, GRatio], [-GRatio, -NormOne, 0], [0, -GRatio, NormOne]], noise: Noise),
        SubDivTriangle(center: position, corners: [[-NormOne, 0, GRatio], [-GRatio, -NormOne, 0], [-GRatio, NormOne, 0]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, -GRatio, -NormOne], [-GRatio, -NormOne, 0], [0, -GRatio, NormOne]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, -GRatio, -NormOne], [GRatio, -NormOne, 0], [0, -GRatio, NormOne]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, -GRatio, -NormOne], [GRatio, -NormOne, 0], [NormOne, 0, -GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, -GRatio, -NormOne], [-NormOne, 0, -GRatio], [NormOne, 0, -GRatio]], noise: Noise),
        SubDivTriangle(center: position, corners: [[0, -GRatio, -NormOne], [-NormOne, 0, -GRatio], [-GRatio, -NormOne, 0]], noise: Noise)
    ]
}

func getSubTriangles(tri: SubDivTriangle) -> [SubDivTriangle] {
    if tri.SubTriangles.count == 0 {
        return [tri]
    } else {
        var tris: [SubDivTriangle] = []
        for i in tri.SubTriangles {
            for j in getSubTriangles(tri: i) {
                tris.append(j)
            }
        }
        return tris
    }
}
