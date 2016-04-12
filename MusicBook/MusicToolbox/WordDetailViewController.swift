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
        
        self.navigationItem.title = word.spelling!
        
        let explanations = word.explanations!.enumerate().map { (index, explanation) -> String in
            "\(index + 1). \((explanation as! WordExplanation).explanation!)"
        }.joinWithSeparator("<br /><br />") + "<br /><br /><br />" + "<style>* {font-family: Arial, Helvetica, sans-serif; font-size: 15px;}</style>"

        explanationBox.textContainerInset = UIEdgeInsetsMake(20, 30, 0, 30)
        
        do {
            let attributedString = try NSAttributedString(data: explanations.dataUsingEncoding(NSUTF8StringEncoding)!, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
            
            explanationBox.attributedText = attributedString
            explanationBox.showsVerticalScrollIndicator = false
        } catch {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
