//
//  UI.swift
//  Graphics
//
//  Created by Charlie Close on 13/06/2023.
//

import SwiftUI

struct UI: View {
    @EnvironmentObject var gameScene: GameScene
    let screenSize: CGRect = UIScreen.main.bounds
    @State var FingerDown = false
    @State var PreviousCoords = CGPoint(x: 0, y: 0)
    @State var CircleCoords = CGPoint(x: 0, y: 0)
    @State var MoveCoords = CGPoint(x: 0, y: 0)
    @State var moveOpacity: Double = 0
    @State var maybeTap: Bool = false
    @State var defTap: Bool = false
    
    var body: some View {
        HStack(spacing: 0){
            Rectangle()
                .foregroundColor(.red)
                .opacity(0.001)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if moveOpacity == 0 {
                                withAnimation(Animation.easeInOut(duration: 0.2)) {
                                    moveOpacity = 0.4
                                }
                                CircleCoords = CGPoint(x: gesture.startLocation.x - screenSize.width / 2, y: gesture.startLocation.y - screenSize.height / 2)
                            }

                            var offset = gesture.translation

                            let size = pow(pow(offset.width, 2) + pow(offset.height, 2), 0.5)

                            if size > 50 {
                                offset.width *= 50 / size
                                offset.height *= 50 / size
                            }

                            MoveCoords = CircleCoords
                            MoveCoords.x += offset.width
                            MoveCoords.y += offset.height
                            gameScene.movePlayer(offset: offset)
                        }
                        .onEnded { _ in
                            moveOpacity = 0
                            gameScene.movePlayer(offset: CGSize(width: 0, height: 0))
                        }
                )
            Rectangle()
                .foregroundColor(.green)
                .opacity(0.001)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if (maybeTap) {
                                defTap = true
                            }
                            if (defTap) {
                                gameScene.vertPlayer(y: gesture.translation.height)
                            } else {
                                if FingerDown {
                                    gameScene.spinPlayer(current: gesture.location, start: PreviousCoords)
                                } else {
                                    FingerDown = true
                                }
                                PreviousCoords = gesture.location
                            }
                        }
                        .onEnded { _ in
                            FingerDown = false
                            defTap = false
                            gameScene.vertPlayer(y: 0)
                        }
                )
                .onTapGesture {
                    maybeTap = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        maybeTap = false
                    }
                }
        }
        .overlay {
            Circle()
                .strokeBorder(.white, lineWidth: 6)
                .offset(x: 50, y: 50)
                .position(CircleCoords)
                .opacity(moveOpacity)
                .frame(width: 100, height: 100)
        }
        .overlay {
            Circle()
                .strokeBorder(.white, lineWidth: 6)
                .offset(x: 25, y: 25)
                .position(MoveCoords)
                .opacity(moveOpacity)
                .frame(width: 50, height: 50)
        }
//        .gesture(
//            DragGesture()
//                .onChanged { gesture in
//                    if (gesture.startLocation.x > screenSize.width / 2) {
//                        if FingerDown {
//                            gameScene.spinPlayer(current: gesture.location, start: PreviousCoords)
//                        } else {
//                            FingerDown = true
//                        }
//                        PreviousCoords = gesture.location
//                    } else {
//                        if moveOpacity == 0 {
//                            withAnimation(Animation.easeInOut(duration: 0.2)) {
//                                moveOpacity = 0.4
//                            }
//                            CircleCoords = CGPoint(x: gesture.startLocation.x - screenSize.width / 2, y: gesture.startLocation.y - screenSize.height / 2)
//                        }
//
//                        var offset = gesture.translation
//
//                        let size = pow(pow(offset.width, 2) + pow(offset.height, 2), 0.5)
//
//                        if size > 50 {
//                            offset.width *= 50 / size
//                            offset.height *= 50 / size
//                        }
//
//                        MoveCoords = CircleCoords
//                        MoveCoords.x += offset.width
//                        MoveCoords.y += offset.height
//                        gameScene.movePlayer(offset: offset)
//                    }
//                }
//                .onEnded { _ in
//                    FingerDown = false
//                    moveOpacity = 0
//                    gameScene.movePlayer(offset: CGSize(width: 0, height: 0))
//                }
//        )
        .ignoresSafeArea()
//        Circle()
//            .strokeBorder(.black, lineWidth: 6)
//            .frame(width: 100, height: 100)
//            .position(x: screenSize.width - 100, y: screenSize.height - 100)
    }
}

struct UI_Previews: PreviewProvider {
    static var previews: some View {
        UI()
    }
}
