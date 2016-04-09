//
//  Word.swift
//  MusicToolbox
//
//  Created by An Wu on 4/8/16.
//  Copyright © 2016 An Wu. All rights reserved.
//

import UIKit

class Word: NSObject {
    var spelling: String
    var explanation: String
    
    init(spelling: String, explanation: String) {
        self.spelling = spelling
        self.explanation = explanation
        
        super.init()
    }
}
