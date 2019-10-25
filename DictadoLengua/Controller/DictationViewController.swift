//
//  ViewController.swift
//  DictadoLengua
//
//  Created by Daniel Alesanco on 18/10/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit
import AudioToolbox

class DictationViewController: UIViewController, UITextFieldDelegate {

    //------------------------------------------------------
    // MARK: - Outlet references

    @IBOutlet var dictadoTextView: UITextView!
    @IBOutlet var whiteBackground: UIImageView!
    @IBOutlet var correctedWordTextField: UITextField!
    @IBOutlet var correctedWordUIView: UIView!
    @IBOutlet var correctedWordHeightConstraint:  NSLayoutConstraint!

    //------------------------------------------------------
    // MARK: - Global Variables

    private let originalText = "Todas las tardes, a la salida de la escuela, los niños se habían acostumbrado a ir a jugar al jardín del gigante. Era un jardín grande y hermoso, cubierto de verde y suave césped. Dispersas sobre la hierba brillaban bellas flores como estrellas, y había una docena de melocotones que, en primavera, se cubrían de delicados capullos rosados, y en otoño daban sabroso fruto. \n\nLos pájaros se posaban en los árboles y cantaban tan deliciosamente que los niños interrumpían sus juegos para escucharlos."
    
    //------------------------------------------------------
    // MARK: - Variables controlled by home View Controller
    
    var dictationOptions = Set<String>()
    
    private var selectedWordRange = UITextRange()
    private var selectedWord = ""   // global var to check is selected word has changed from dictation (to change the color of the word)
    private var correctedDictationText = NSMutableAttributedString()

    //------------------------------------------------------
    // MARK: - View did load

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialization
        whiteBackground.alpha = 0
        correctedWordHeightConstraint.constant = 0
        
        correctedWordTextField.delegate      = self

        // Add notification for keyboard heigth change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification,object:nil)
        
        // Add tap gesture to modify a word
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnTextView(_:)))
        dictadoTextView.addGestureRecognizer(tapGesture)
        
        // generates dictation
        let dictationText       = writeDictation(from: originalText)

        // initializes correctedDictationText as attributed text with format
        correctedDictationText = formatDictado(dictationText)
        
        // shows dictation on textview
        dictadoTextView.attributedText = formatDictado(dictationText)
        dictadoTextView.isEditable      = false
        dictadoTextView.isSelectable    = false
    }
    
    
    //------------------------------------------------------
    // MARK: - remove notification observer when app finish
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    //------------------------------------------------------
    // MARK: - write dictation with options method
    
    private func writeDictation(from text: String) -> String {
        
        var dictation = text
        
        if dictationOptions.contains("Tilde") {
            dictation = removeAcent(from: text)
        }
        
        dictation = addRandomErrors(in: dictation, with: dictationOptions)
        
        return dictation
    }
    
    // returns a dictado without accent marks
    private func removeAcent(from dictado : String) -> String {
        return  dictado.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    // adds random errors to dictation according to selected options
    private func addRandomErrors(in dictado: String, with dictationOptions: Set<String>) -> String{
        
        var result = ""
        
        var modDictado  = dictado.replacingOccurrences(of: "gu", with: ";;")
        modDictado      = modDictado.replacingOccurrences(of: "ll", with: "`")
        modDictado      = modDictado.replacingOccurrences(of: " y ", with: ":::")

        for char in modDictado {
            if dictationOptions.contains("B / V") && (char == "b" || char == "v") {
                Bool.random() ? result.append("b") : result.append("v")
            }
            
            else if dictationOptions.contains("G / J") && (char == "g" || char == "j") {
                Bool.random() ? result.append("g") : result.append("j")
            }
                
            else if dictationOptions.contains("LL / Y") && (char == "`" || char == "y") {
                Bool.random() ? result.append("ll") : result.append("y")
            }
                
            else if dictationOptions.contains("H") && (char == "h") {
                Bool.random() ? result.append("h") : result.append("")
            }
            
            else {
                result.append(char)
            }
        }
        
        result = result.replacingOccurrences(of: ";;", with: "gu")
        result = result.replacingOccurrences(of: ":::", with: " y ")
        result = result.replacingOccurrences(of: "`", with: "ll")

        return  result
    }
    
    //------------------------------------------------------
    // MARK: - tap on textView event
    // Selects the word tapped and shows it on label
    
    @objc private final func tapOnTextView(_ tapGesture: UITapGestureRecognizer){
        
        // Blurs the dictation and shows the text field with the word tapped
        whiteBackground.alpha       = 0.8
        correctedWordTextField.becomeFirstResponder()
        
        let point = tapGesture.location(in: dictadoTextView)
        if let getWord = getWordAtPosition(point) {
            selectedWord = getWord
            correctedWordTextField.text = selectedWord
        }
    }
    
    // gets the word closest to user tapped point
    private func getWordAtPosition(_ point: CGPoint) -> String? {

        if let textPosition = dictadoTextView.closestPosition(to: point) {
            if let range = dictadoTextView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1)) {
                selectedWordRange = range
                return dictadoTextView.text(in: selectedWordRange)
            }
        }
        return nil
    }
    
    //------------------------------------------------------
    //MARK:- keyboard will change frame notification
    
    @objc private func keyboardNotification(notification: NSNotification) {

        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                
                let keyboardYPos = keyboardSize.origin.y
                
                if keyboardYPos < UIScreen.main.bounds.size.height {  // keyboard shown
                    self.correctedWordHeightConstraint.constant = keyboardSize.size.height  + 50
                } else {
                    self.correctedWordHeightConstraint.constant = 0 //heigth of the message view when it's on the bottom side
                }
                
                let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: .curveLinear,
                               animations: { self.view.layoutIfNeeded() },
                               completion: nil)
            }
        }
    }
    
    //------------------------------------------------------
    //MARK:- dismiss keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let modifiedWord = textField.text {
            
            // is selected word has been modified change it on the dictation
            if !(modifiedWord == selectedWord) {
                setWordAtRange(with: modifiedWord, in: selectedWordRange)
            }
        }
        
        dismissKeyboard()
        return true
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        
        if let modifiedWord = correctedWordTextField.text {
            
            // is selected word has been modified change it on the dictation
            if !(modifiedWord == selectedWord) {
                setWordAtRange(with: modifiedWord, in: selectedWordRange)
            }
        }
        
        AudioServicesPlaySystemSound(1156)
        dismissKeyboard()
    }
    
    private func dismissKeyboard(){
        whiteBackground.alpha       = 0
        correctedWordTextField.resignFirstResponder()
        view.endEditing(true)
    }
    
    //------------------------------------------------------
    //MARK:- setWordAtRange
    
    private func setWordAtRange(with word:String, in range: UITextRange){
        
        let startIndexInt   = dictadoTextView.offset(from: dictadoTextView.beginningOfDocument, to: range.start)
        let endIndexInt     = dictadoTextView.offset(from: dictadoTextView.beginningOfDocument, to: range.end)

        let range = NSRange(location: startIndexInt, length: endIndexInt - startIndexInt)
        
        correctedDictationText.mutableString.replaceCharacters(in: range, with: word)
           
        correctedDictationText.addAttribute(.foregroundColor, value: UIColor.orange, range: range)

        dictadoTextView.attributedText = correctedDictationText

    }
}

