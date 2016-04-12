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

        explanationBox.textContainerInset = UIEdgeInsetsMake(20, 30, 0, 30)
        
        let mutableAttributedString = NSMutableAttributedString()
        word.explanations!.forEach({ (explanationObj) in
            let explanation = explanationObj as! WordExplanation
            let attributedString = try? NSAttributedString(data: explanation.encodedStr!.dataUsingEncoding(NSUTF8StringEncoding)!, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
            mutableAttributedString.appendAttributedString(attributedString!)
        })
        
        explanationBox.attributedText = mutableAttributedString
        explanationBox.showsVerticalScrollIndicator = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
