//
//  Perlin3D.swift
//  Graphics
//
//  Created by Charlie Close on 14/06/2023.
//

import Foundation
import UIKit

public class Perlin3D: NSObject {
    var permutation:[Int] = []
    
    
    public init(seed: String) {
        
        let hash = seed.hash
        
        srand48(hash)
        
        for _ in 0..<255 {
            //Create the permutations to pick from using a seed so you can recreate the map
            permutation.append(Int(drand48() * 255))
        }
    }
    
    func perm(val: CGFloat) -> Int {
        return permutation[abs(Int(val) % 255)]
    }
    
    func lerp(a:CGFloat, b:CGFloat, x:CGFloat) -> CGFloat {
        return a + x * (b - a) //This interpolates between two points with a weight x
    }
    
    func fade(t:CGFloat) -> CGFloat {
        return t * t * t * (t * (t * 6 - 15) + 10) //This is the smoothing function for Perlin noise
    }
    
    func grad(hash:Int, x:CGFloat, y:CGFloat, z:CGFloat) -> CGFloat {
        
        let h = hash & 15
        let u = h > 8 ? x : y
        let v = h < 4 ? y : h == 12 || h == 14 ? x : z
        return ((h & 1 != 0) ? -u : u) + ((h & 2 != 0) ? -v : v)
        
        //This takes a hash (a number from 0 - 11) generated from the random permutations and returns a random
        //operation for the node to offset
        
//        switch hash & 11 {
//        case 0:
//            return x + y
//        case 1:
//            return -x + y
//        case 2:
//            return x - y
//        case 3:
//            return -x - y
//        case 4:
//            return x + z
//        case 5:
//            return -x + z
//        case 6:
//            return x - z
//        case 7:
//            return -x - z
//        case 8:
//            return y + z
//        case 9:
//            return -y + z
//        case 10:
//            return y - z
//        case 11:
//            return -y - z
//        default:
//            print("ERROR")
//            return 0
//        }
        
        
    }
    
    func fastfloor(x:CGFloat) -> Int {
        return x > 0 ? Int(x) : Int(x-1)
    }
    
    public func noise(x:Double, y:Double, z:Double) -> Double {
        
        let F3: Double = 1 / 3
        let G3: Double = 1 / 6
        
        let s = (x + y + z) * F3
        let i = Double(fastfloor(x: x + s))
        let j = Double(fastfloor(x: y + s))
        let k = Double(fastfloor(x: z + s))
        
        let t = (i + j + k) * G3
        let X0 = i - t
        let Y0 = j - t
        let Z0 = k - t
        let x0 = x - X0
        let y0 = y - Y0
        let z0 = z - Z0
        
        var i1: Double = 0
        var j1: Double = 0
        var k1: Double = 0
        var i2: Double = 0
        var j2: Double = 0
        var k2: Double = 0
        
        if x0 >= y0 {
            if (y0 >= z0) {
                i1 = 1; j1 = 0; k1 = 0; i2 = 1; j2 = 1; k2 = 0; // X Y Z order
            } else if (x0 >= z0) {
                i1 = 1; j1 = 0; k1 = 0; i2 = 1; j2 = 0; k2 = 1; // X Z Y order
            } else {
                i1 = 0; j1 = 0; k1 = 1; i2 = 1; j2 = 0; k2 = 1; // Z X Y order
            }
        } else { // x0<y0
            if (y0 < z0) {
                i1 = 0; j1 = 0; k1 = 1; i2 = 0; j2 = 1; k2 = 1; // Z Y X order
            } else if (x0 < z0) {
                i1 = 0; j1 = 1; k1 = 0; i2 = 0; j2 = 1; k2 = 1; // Y Z X order
            } else {
                i1 = 0; j1 = 1; k1 = 0; i2 = 1; j2 = 1; k2 = 0; // Y X Z order
            }
        }
        
        let x1 = x0 - i1 + G3; // Offsets for second corner in (x,y,z) coords
        let y1 = y0 - j1 + G3;
        let z1 = z0 - k1 + G3;
        let x2 = x0 - i2 + 2.0 * G3; // Offsets for third corner in (x,y,z) coords
        let y2 = y0 - j2 + 2.0 * G3;
        let z2 = z0 - k2 + 2.0 * G3;
        let x3 = x0 - 1.0 + 3.0 * G3; // Offsets for last corner in (x,y,z) coords
        let y3 = y0 - 1.0 + 3.0 * G3;
        let z3 = z0 - 1.0 + 3.0 * G3;
        
        let gi0 = perm(val: i + Double(perm(val: j + Double(perm(val: k)))));
        let gi1 = perm(val: i + i1 + Double(perm(val: j + j1 + Double(perm(val: k + k1)))));
        let gi2 = perm(val: i + i2 + Double(perm(val: j + j2 + Double(perm(val: k + k2)))));
        let gi3 = perm(val: i + 1 + Double(perm(val: j + 1 + Double(perm(val: k + 1)))));
        
        var n0: Double = 0
        var n1: Double = 0
        var n2: Double = 0
        var n3: Double = 0
        var t0 = 0.6 - x0*x0 - y0*y0 - z0*z0;
        if (t0 < 0) {
            n0 = 0.0;
        } else {
            t0 *= t0;
            n0 = t0 * t0 * grad(hash: gi0, x: x0, y: y0, z: z0);
        }
        var t1 = 0.6 - x1*x1 - y1*y1 - z1*z1;
        if (t1 < 0) {
            n1 = 0.0;
        } else {
            t1 *= t1;
            n1 = t1 * t1 * grad(hash: gi1, x: x1, y: y1, z: z1);
        }
        var t2 = 0.6 - x2*x2 - y2*y2 - z2*z2;
        if (t2 < 0) {
            n2 = 0.0;
        } else {
            t2 *= t2;
            n2 = t2 * t2 * grad(hash: gi2, x: x2, y: y2, z: z2);
        }
        var t3 = 0.6 - x3*x3 - y3*y3 - z3*z3;
        if (t3 < 0) {
            n3 = 0.0;
        } else {
            t3 *= t3;
            n3 = t3 * t3 * grad(hash: gi3, x: x3, y: y3, z: z3);
        }
        // Add contributions from each corner to get the final noise value.
        // The result is scaled to stay just inside [-1,1]
        return 32.0*(n0 + n1 + n2 + n3);
        
//        //Find the unit grid cell containing the point
//        var xi = fastfloor(x: x)
//        var yi = fastfloor(x: y)
//        var zi = fastfloor(x: z)
//
//        //This is the other bound of the unit square
//        let xf:CGFloat = x - CGFloat(xi)
//        let yf:CGFloat = y - CGFloat(yi)
//        let zf:CGFloat = z - CGFloat(zi)
//
//        //Wrap the ints around 255
//        xi = xi & 255
//        yi = yi & 255
//        zi = zi & 255
//
//        //These are offset values for interpolation
//        let u = fade(t: xf)
//        let v = fade(t: yf)
//        let w = fade(t: zf)
//
//        //These are the 8 possible permutations so we get the perm value for each
//        let aaa = permutation[permutation[permutation[xi] + yi] + zi]
//        let aab = permutation[permutation[permutation[xi] + yi] + zi + 1]
//        let aba = permutation[permutation[permutation[xi] + yi + 1] + zi]
//        let abb = permutation[permutation[permutation[xi] + yi + 1] + zi + 1]
//        let baa = permutation[permutation[permutation[xi + 1] + yi] + zi]
//        let bab = permutation[permutation[permutation[xi + 1] + yi] + zi]
//        let bba = permutation[permutation[permutation[xi + 1] + yi + 1] + zi]
//        let bbb = permutation[permutation[permutation[xi + 1] + yi + 1] + zi + 1]
//
//
//        //We pair up the permutations, and then interpolate the noise contributions
//
//        let naa = lerp(a: grad(hash: aaa, x: xf, y: yf, z: zf), b: grad(hash: baa, x: xf, y: yf, z: zf), x: u)
//        let nab = lerp(a: grad(hash: aab, x: xf, y: yf, z: zf), b: grad(hash: bab, x: xf, y: yf, z: zf), x: u)
//        let nba = lerp(a: grad(hash: aba, x: xf, y: yf, z: zf), b: grad(hash: bba, x: xf, y: yf, z: zf), x: u)
//        let nbb = lerp(a: grad(hash: abb, x: xf, y: yf, z: zf), b: grad(hash: bbb, x: xf, y: yf, z: zf), x: u)
//
//        let na = lerp(a: naa, b: nba, x: v)
//        let nb = lerp(a: nab, b: nbb, x: v)
//
//        let nxyz = lerp(a: na, b: nb, x: w)
//
//        //We return the value + 1 / 2 to remove any negatives.
//        return (nxyz + 1) / 2
    }
    
    
    public func octaveNoise(x:CGFloat, y:CGFloat, z:CGFloat, octaves:Int, persistence:CGFloat) -> CGFloat {
        
        //This takes several perlin readings (n octaves) and merges them into one map
        var total:CGFloat = 0
        var frequency: CGFloat = 1
        var amplitude: CGFloat = 1
        var maxValue: CGFloat = 0
        
        //We sum the total and divide by the max at the end to normalise
        for _ in 0..<octaves {
            total += noise(x: x * frequency, y: y * frequency, z: z * frequency) * amplitude
            
            maxValue += amplitude
            
            //This is taken from recomendations on values
            amplitude *= persistence
            frequency *= 2
        }
        
        //print(max)
        
        return total/maxValue
    }
    
    
    public func perlinMatrix(width:Int, height: Int, length: Int) -> [[[CGFloat]]] {
        
        var map:[[[CGFloat]]] = []
        
        //We loop through the x and y values and scale by 50. This is an arbritatry value to scale the map
        //You can play with this
        for x in (0...width) {
            
            var row1:[[CGFloat]] = []
            
            for y in (0...height) {
                
                var row2:[CGFloat] = []
                
                for z in (0...length) {
                    
                    let cx:CGFloat = CGFloat(x)/50
                    let cy:CGFloat = CGFloat(y)/50
                    let cz:CGFloat = CGFloat(z)/50
                    
                    let p = noise(x: cx, y: cy, z: cz)
                    
                    row2.append(p)
                }
                
                row1.append(row2)
            }
            
            //We store the map in a matrix for fast access
            map.append(row1)
        }
        
        return map
        
        
    }
    
    
    public func octaveMatrix(width:Int, height: Int, length: Int, octaves:Int, persistance:CGFloat) -> [[[CGFloat]]] {
        
        var map:[[[CGFloat]]] = []
        
        //We loop through the x and y values and scale by 50. This is an arbritatry value to scale the map
        //You can play with this
        for x in (0...width) {
            
            var row1:[[CGFloat]] = []
            
            for y in (0...height) {
                
                var row2:[CGFloat] = []
                
                for z in (0...length) {
                    
                    let cx:CGFloat = CGFloat(x)/50
                    let cy:CGFloat = CGFloat(y)/50
                    let cz:CGFloat = CGFloat(z)/50
                    
                    //We decide to use 8 octaves and 0.25 to generate our map. You can change these too
                    let p = octaveNoise(x: cx, y: cy, z: cz, octaves: octaves, persistence: persistance)
                    
                    row2.append(p)
                }
                
                row1.append(row2)
            }
            map.append(row1)
        }
        
        return map
        
        
    }
}
