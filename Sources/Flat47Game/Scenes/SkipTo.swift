//
//  File.swift
//  
//
//  Created by x414e54 on 17/06/2021.
//

import Foundation

case "SkipTo":
	let skipToScene: Int = sceneData?["SkipTo"] as! Int
	let flag: String? = (sceneData?["Flag"] as? String?)!
	
	var shouldSkip: Bool = true;
	
	if (flag != nil) {
		shouldSkip = !flags.contains(flag!)
	}
	
	if (shouldSkip) {
		setScene(index: skipToScene)
	} else {
		setScene(index: self.currentSceneIndex! + 1)
	}
	return
