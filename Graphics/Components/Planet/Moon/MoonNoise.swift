//
//  MoonNoise.swift
//  Graphics
//
//  Created by Charlie Close on 25/06/2023.
//

class MoonNoise: NoiseProtocol {

    let MBiomeNoise: Perlin3D
    let MountainNoise: Perlin3D
    
    init() {
        MBiomeNoise = Perlin3D(seed: "MBiome")
        MountainNoise = Perlin3D(seed: "Mountain")
    }
    
    func value(pos: simd_double3) -> Double {
        let x = pos[0]
        let y = pos[1]
        let z = pos[2]
        
        let MBiome = min(max(0.2 - abs(MBiomeNoise.noise(x: x / 2, y: y / 2, z: z / 2)), 0), 0.05) * 4
        let Mountain = max((MountainNoise.noise(x: x * 15, y: y * 15, z: z * 15) + 1), 0) * 0.03;
        return 0.5 + MBiome * Mountain
    }
    
    func getNormal(pos: simd_double3) -> simd_float3 {
        let nPos = normalize(pos)
        let d: Double = 0.0001
        let value = self.value(pos: pos)
        let truePos = nPos * value
        
        var horiz: simd_double3 = [nPos[1], -nPos[0], 0]
        if (horiz == [0, 0, 0]) {
            horiz = [nPos[2], 0, -nPos[0]]
        }
        horiz = normalize(horiz)
        let vert = cross(horiz, nPos)
        
        let horizPos = pos + horiz * d
        let vertPos = pos + vert * d
        
        let trueHoriz = horizPos * self.value(pos: horizPos)
        let trueVert = vertPos * self.value(pos: vertPos)
        
        var norm = normalize(cross(trueHoriz - truePos, trueVert - truePos))
        
        if (dot(norm, nPos) < 0) {
            norm = -norm
        }
        
        return simd_float3(norm)
    }
        
    func Colour(pos: simd_double3, norm: simd_float3) -> simd_float4 {
        let flat = dot(simd_double3(norm), normalize(pos))
        let _ = self.value(pos: pos)

        return [0.4, 0.4, 0.5, 1]
    }
}
