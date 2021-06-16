//
//  GameSubScene.swift
//  RevengeOfTheSamurai
//
//  Created by x414e54 on 16/06/2021.
//

import SpriteKit

// Obvious what goes here!
@available(iOS 10.0, *)
class GameSubScene : SKNode { // TODO Move more of SKNode's functionality into here to remove dependance for later porting if needed.

	var gameLogic: GameLogic?
	
	public init(gameLogic: GameLogic?) {
		super.init()
		self.gameLogic = gameLogic
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
	}
	
	func interactionMoved(_ point: CGPoint, timestamp: TimeInterval) {
	}
	
	func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
	}
}
