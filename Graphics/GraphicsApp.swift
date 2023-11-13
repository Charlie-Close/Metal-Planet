//
//  GraphicsApp.swift
//  Graphics
//
//  Created by Charlie Close on 11/06/2023.
//

import SwiftUI

@main
struct GraphicsApp: App {
    
    @StateObject private var gameScene = GameScene()
    
//    let screenSize: CGRect = UIScreen.main.bounds
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .frame(width: screenSize.height, height: screenSize.width)
                .environmentObject(gameScene)
                .overlay {
                    UI()
                        .environmentObject(gameScene)
                }
                .ignoresSafeArea()
        }
    }
}
