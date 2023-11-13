//
//  Renderer.swift
//  Graphics
//
//  Created by Charlie Close on 11/06/2023.
//

import MetalKit


class Renderer: NSObject, MTKViewDelegate {
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    var scene: GameScene
    
    init(scene: GameScene) {
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        scene.addPlanets(metalDevice: metalDevice)
        self.metalCommandQueue = metalDevice.makeCommandQueue()
                
        self.scene = scene
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView){
        scene.update()
         
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        let farRenderPassDescriptor = view.currentRenderPassDescriptor
        farRenderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        farRenderPassDescriptor?.colorAttachments[0].loadAction = .clear
        farRenderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let farRenderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: farRenderPassDescriptor!)
                
        let cameraView = Matrix44.create_lookat(eye: scene.player.position, target: scene.player.position + scene.player.forwards, up: scene.player.up)
        
        scene.sortPlanets()
        
        for body in scene.farPlanets {
            body.drawMesh(cameraView: cameraView, view: view, renderEncoder: farRenderEncoder!, metalDevice: metalDevice, position: scene.player.position)
        }
        
        farRenderEncoder?.endEncoding()
        
        let nearRenderPassDescriptor = view.currentRenderPassDescriptor
        nearRenderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        nearRenderPassDescriptor?.colorAttachments[0].loadAction = .load
        nearRenderPassDescriptor?.colorAttachments[0].storeAction = .store
        nearRenderPassDescriptor?.depthAttachment.clearDepth = 1.0
        
        let nearRenderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: nearRenderPassDescriptor!)
                
        for body in scene.nearPlanets {
            body.drawMesh(cameraView: cameraView, view: view, renderEncoder: nearRenderEncoder!, metalDevice: metalDevice, position: scene.player.position)
        }
        
        nearRenderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
