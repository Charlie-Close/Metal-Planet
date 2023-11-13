//
//  RenderMesh.swift
//  Graphics
//
//  Created by Charlie Close on 24/06/2023.
//

import MetalKit

struct parameter {
    let pointer: UnsafeRawPointer
    let length: Int
}

class MeshRenderer {
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    let pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    
    init (vertexShader: String, fragmentShader: String, transparent: Bool = false) {
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: vertexShader)
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: fragmentShader)
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        if transparent {
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = metalDevice.makeDepthStencilState(descriptor: depthStencilDescriptor )!
    }
    
    func drawMeshes(meshes: [Mesh], near: Float, far: Float, cameraView: matrix_float4x4, view: MTKView, renderEncoder: MTLRenderCommandEncoder, parameters: [parameter]) {
                
        let cameraProjection = Matrix44.create_perspective_projection(fovy: 45, aspect: Float(view.frame.height / view.frame.width), near: near, far: far)
        
        var cameraMatrix = cameraProjection * cameraView
                
        renderEncoder.setVertexBytes(&cameraMatrix, length: MemoryLayout<CameraParameters>.stride, index: 1 )
        var index = 2
        for par in parameters {
            renderEncoder.setVertexBytes(par.pointer, length: par.length, index: index )
            index += 1
        }
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
                
        for mesh in meshes {
            renderEncoder.setVertexBuffer(mesh.VertexBuffer, offset: 0, index: 0)
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: mesh.Length, indexType: .uint32, indexBuffer: mesh.IndexBuffer, indexBufferOffset: 0)
        }
    }
}
