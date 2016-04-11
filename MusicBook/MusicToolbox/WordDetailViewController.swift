//
//  WordDetailViewController.swift
//  MusicBook
//
//  Created by An Wu on 4/10/16.
//  Copyright © 2016 An Wu. All rights reserved.
//

import UIKit

class WordDetailViewController: UIViewController {
    
    // MARK: Properties
    var word: Word!
    @IBOutlet weak var explanationBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let explanations = word.explanations!.enumerate().map { (index, explanation) -> String in
            "\(index + 1). \((explanation as! WordExplanation).explanation!)"
        }

        explanationBox.textContainerInset = UIEdgeInsetsMake(15, 30, 0, 30)
        
        let font = UIFont(name: "Palatino-Roman", size: 14.0)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let attributedString = NSMutableAttributedString(string: explanations.joinWithSeparator("\n\n") + "\n\n\n")
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSFontAttributeName, value: font!, range: NSRange(location: 0, length: attributedString.length))
        explanationBox.attributedText = attributedString
        explanationBox.showsVerticalScrollIndicator = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
