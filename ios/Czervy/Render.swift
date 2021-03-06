//
//  test.swift
//  Czervy
//
//  Created by master on 8/13/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import Foundation
import UIKit
import Metal
import QuartzCore

@available(iOS 8.0, *)

@objc (Render)
class Render: NSObject, UIGestureRecognizerDelegate {
  
  var view:          UIView!                 = nil
  var device:        MTLDevice!              = nil
  var metalLayer:    CAMetalLayer!           = nil
  var vertexBuffer:  MTLBuffer!              = nil
  var pipelineState: MTLRenderPipelineState! = nil
  var commandQueue:  MTLCommandQueue!        = nil
  var timer:         CADisplayLink!          = nil
  
  let vertexData: [Float] = [
                               0.0,  1.0, 0.0,
                              -1.0, -1.0, 0.0,
                               1.0, -1.0, 0.0
                            ]
  
  // IMPORTANT!!! when the bridge is loading it needs this method
  override init() {
    super.init()
  }
  
  init(view: UIView) {
    super.init()
    
    self.view = view
    
    // Create a MTLDevice
    self.device = MTLCreateSystemDefaultDevice()!

    // Create a CAMetalLayer
    self.metalLayer                 = CAMetalLayer()
    self.metalLayer.device          = device
    self.metalLayer.pixelFormat     = .BGRA8Unorm
    self.metalLayer.framebufferOnly = true
    self.metalLayer.frame           = view.layer.frame
    
    self.view.layer.addSublayer(metalLayer)
    
    // Create a Vertex Buffer
    let dataSize      = vertexData.count * sizeofValue(vertexData[0])// 1
    self.vertexBuffer = device.newBufferWithBytes(vertexData,
                                                   length: dataSize,
                                                   options: .CPUCacheModeDefaultCache)
    
    
    
    // Create a Render Pipeline
    let defaultLibrary  = device.newDefaultLibrary()
    let fragmentProgram = defaultLibrary!.newFunctionWithName("basic_fragment")
    let vertexProgram   = defaultLibrary!.newFunctionWithName("basic_vertex")

    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    
    pipelineStateDescriptor.vertexFunction                  = vertexProgram
    pipelineStateDescriptor.fragmentFunction                = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
    
    do {
      self.pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
    } catch let error {
      print("error -> ", error)
    }
    
    // Create a Command Queue
    self.commandQueue = device.newCommandQueue()
    
    
    
    /**           Rendering a triangle
    */
    
    // Create a Display Link - the timer fires every frame
    self.timer = CADisplayLink(target: self, selector: #selector(Render.gameloop))
    self.timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    
    // Add gesture recogniser
    let gRec = UIPanGestureRecognizer(target: self, action: #selector(Render.handleOrientation))
    gRec.delegate = self
    self.view.addGestureRecognizer(gRec)
  }
  
  func handleOrientation(gestureRecogniser: UIGestureRecognizer) {
    print(gestureRecogniser.locationInView(self.view))
  }
  
  func render() {
    // Create a Render Pass Descriptor
    let renderPassDescriptor = MTLRenderPassDescriptor()
    let drawable = metalLayer.nextDrawable()!
    
    renderPassDescriptor.colorAttachments[0].texture    = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .Clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red  : 0.0,
                                                                        green: 104.0/255.0,
                                                                        blue : 5.0/255.0,
                                                                        alpha: 1.0)
    
    // Create a Command Buffer
    let commandBuffer = commandQueue.commandBuffer()
    
    // Create a Render Command Encoder
    let renderEncoderOpt = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
    
    renderEncoderOpt.setRenderPipelineState(pipelineState)
    renderEncoderOpt.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
    renderEncoderOpt.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    renderEncoderOpt.endEncoding()
  
    // Commit your Command Buffer
    commandBuffer.presentDrawable(drawable)
    commandBuffer.commit()
  }
  
  func gameloop() {
    autoreleasepool {
      self.render()
    }
  }
  
  @objc func test_render() {
    print("got 'eeem nigga")
  }
}