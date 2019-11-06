//
//  ResultadoViewController.swift
//  DictadoLengua
//
//  Created by Daniel Alesanco on 23/10/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    var originalText            = String()
    var correctedDictationText  = String()

    @IBOutlet weak var originalTextView: UITextView!
    @IBOutlet weak var correctedDictationView: UITextView!
    @IBOutlet weak var errorNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated:false);
       
        let originalTextArray  = originalText.components(separatedBy: " ")
        let correctedTextArray = correctedDictationText.components(separatedBy: " ")
                
        // Calculate words different between original and corrected text arrays
        let difference = originalTextArray.difference(from: correctedTextArray)
        
        // shows number of errors in label
        errorNumberLabel.text = "Número de errores: \(difference.insertions.count)"
        
        // Indexes of words different are saved in two arrays one for the original and another one for the corrected
        var wrongWordsOriginalTextArray  = [Int]()
        var wrongWordsCorrectedTextArray = [Int]()

        for change in difference {
            switch change {
            case let .remove(offset, _, _):
                wrongWordsOriginalTextArray.append(offset)
                
            case let .insert( offset, _, _):
                wrongWordsCorrectedTextArray.append(offset)
            }
        }
      
        // Define array of words with attributes
        let originalTextArrayWithAttributes  = originalTextArray.map { NSMutableAttributedString(string: $0, attributes: [.font: UIFont.systemFont(ofSize: 18)])}
        let correctedTextArrayWithAttributes = correctedTextArray.map{ NSMutableAttributedString(string: $0, attributes: [.font: UIFont.systemFont(ofSize: 18)])}

        // change color attribute of wrong words in arrays
        for wrongWordIndex in wrongWordsOriginalTextArray {
            originalTextArrayWithAttributes[wrongWordIndex].addAttributes([.foregroundColor : UIColor.orange], range: NSRange(location: 0, length:         (originalTextArrayWithAttributes[wrongWordIndex].string.count)))
        }
        for wrongWordIndex in wrongWordsCorrectedTextArray {
            correctedTextArrayWithAttributes[wrongWordIndex].addAttributes([.foregroundColor : UIColor.red], range: NSRange(location: 0, length:         (correctedTextArrayWithAttributes[wrongWordIndex].string.count)))
        }
        
        // convert array of NSattributed Text to NSattribute string
        let originalTextWithAttributes = originalTextArrayWithAttributes.reduce(NSMutableAttributedString(string: "")) {
            $0.append($1)
            $0.append(NSAttributedString(string: " "))
            return $0
        }
        
        let correctedTextWithAttributes = correctedTextArrayWithAttributes.reduce(NSMutableAttributedString(string: "")) {
            $0.append($1)
            $0.append(NSAttributedString(string: " "))
            return $0
        }
        
        // shows texts with error in red
        
        originalTextView.attributedText = originalTextWithAttributes
        correctedDictationView.attributedText = correctedTextWithAttributes
                    
    }
    
    //------------------------------------------------------
    // Gives format to dictado
    private func formatDictado(_ dictado: String) -> NSMutableAttributedString {
            
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 15

        let attributes: [NSMutableAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .paragraphStyle: paragraphStyle
        ]

        return NSMutableAttributedString(string: dictado, attributes: attributes)
    }
    
}
