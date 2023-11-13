//
//  Scene.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//
import MetalKit

class GameScene: ObservableObject {
    
    @Published var player: Camera
    var planets: [PlanetProtocol]
    var nearPlanets: [PlanetProtocol]
    var farPlanets: [PlanetProtocol]
    
    init() {
        player = Camera(
            position: [-5, 0, 0],
            eulers: [0.0, 90.0, 0.0]
        )
        planets = []
        nearPlanets = []
        farPlanets = []
    }
    
    func update() {
        
        player.updateVectors()
//        player.rotateUp(up: normalize(player.position))
        
    }
    
    func addPlanets(metalDevice: MTLDevice) {
        planets = [
            Earth(metalDevice: metalDevice, position: [0, 0, 0]),
            Moon(metalDevice: metalDevice, position: [50, 0, 0]),
        ]
    }
    
    func sortPlanets() {
        var nearest = planets[0];
        var distance: Float = length(planets[0].Position - player.position)
        
        for planet in planets.dropFirst() {
            let newDistance = length(planet.Position - player.position)
            if (newDistance < distance) {
                distance = newDistance
                nearest = planet
            }
        }
        
        nearPlanets = [nearest]
        farPlanets = planets.filter({ body in
            return body.Position != nearest.Position
        })
    }
    
    func spinPlayer(current: CGPoint, start: CGPoint) {
        let dTheta = Float(start.x - current.x)
        let dPhi = Float(start.y - current.y)
        
        player.eulers.z += 0.15 * dTheta
        player.eulers.y += 0.15 * dPhi
        
        if player.eulers.z > 360 {
            player.eulers.z -= 360
        }
        else if player.eulers.z < 0 {
            player.eulers.z += 360
        }
        if player.eulers.y < 10 {
            player.eulers.y = 10
        }
        else if player.eulers.y > 170 {
            player.eulers.y = 170
        }
        
        player.updateVectors()
    }
    
    func movePlayer(offset: CGSize) {
        player.drag = offset
    }
    
    func vertPlayer(y: CGFloat) {
        if (y != 0) {
            player.vert = (-y / abs(y)) * min(abs(y), 50)
        } else {
            player.vert = 0
        }
    }
}
