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

    var tildeDictation  = false
    var bvDictation     = false
    var llyDictation    = false
    var gjDictation     = false
    var hDictation      = false
    
    private var selectedWordRange = UITextRange()
    
    private var modifiedDictation = ""
    
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
        let dictation = writeDictation(from: originalText)
        modifiedDictation = dictation
        
        // shows dictation on textview
        dictadoTextView.attributedText = formatDictado(dictation)
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
    func formatDictado(_ dictado: String) -> NSAttributedString {
            
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 15

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .paragraphStyle: paragraphStyle
        ]

        return NSAttributedString(string: dictado, attributes: attributes)
    }
    
    //------------------------------------------------------
    // MARK: - write dictation with options method
    
    private func writeDictation(from originalText: String) -> String {
        
        var dictation = originalText
        
        if tildeDictation {
            dictation = removeAcent(from: originalText)
        }
        
        if bvDictation {
            dictation = randomBV(in: dictation)
        }
        
        if gjDictation {
            dictation = randomGJ(in: dictation)
        }
        
        if hDictation {
            dictation = randomH(in: dictation)
        }
        if llyDictation {
            dictation = randomLlY(in: dictation)
        }
        return dictation
    }
    
    // returns a dictado without accent marks
    func removeAcent(from dictado : String) -> String {
        return  dictado.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    // returns a dictado with "b" and "v" used randomly
    func randomBV(in dictado : String) -> String {
        
        var result = ""
        
        for char in dictado {
            if char == "b" || char == "v" {
                Bool.random() ? result.append("b") : result.append("v")
            }
            else {
                result.append(char)
            }
        }
        return  result
    }
    
    // returns a dictado with "g" and "j" used randomly
    // The string "gu" is not changed
    func randomGJ(in dictado : String) -> String {
        
        var result = ""
        
        let modDictado = dictado.replacingOccurrences(of: "gu", with: "::")

        for char in modDictado {
            if char == "j" || char == "g" {
                Bool.random() ? result.append("j") : result.append("g")
            }
            else {
                result.append(char)
            }
        }
        
        result = result.replacingOccurrences(of: "::", with: "gu")

        return  result
    }
    
    // returns a dictado with "h" used randomly
    func randomH(in dictado : String) -> String {
        
        var result = ""
        
        for char in dictado {
            if char == "h" {
                Bool.random() ? result.append("h") : result.append("")
            }
            else {
                result.append(char)
            }
        }
        return  result
    }
    
    // returns a dictado with "Ll" and "Y" used randomly
    // When "y" is alone is not replaced
    func randomLlY(in dictado : String) -> String {
        
        var result = ""
        
        var modDictado = dictado.replacingOccurrences(of: "ll", with: "`")
        modDictado = modDictado.replacingOccurrences(of: " y ", with: ":::")

        for char in modDictado {
            if char == "`" || char == "y" {
                Bool.random() ? result.append("ll") : result.append("y")
            }
            else {
                result.append(char)
            }
        }
        
        result = result.replacingOccurrences(of: ":::", with: " y ")

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
        if let detectedWord = getWordAtPosition(point) {
            correctedWordTextField.text = detectedWord
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
    //MARK:- setWordAtRange
    
    private func setWordAtRange(with word:String, in range: UITextRange){
        
        let startIndex :Int = dictadoTextView.offset(from: dictadoTextView.beginningOfDocument, to: range.start)
        let endIndex   :Int = dictadoTextView.offset(from: dictadoTextView.beginningOfDocument, to: range.end)
        
        let startRange = modifiedDictation.index(modifiedDictation.startIndex, offsetBy: startIndex)
        let endRange = modifiedDictation.index(modifiedDictation.startIndex, offsetBy: endIndex)
        
        let range = startRange..<endRange
        dictadoTextView.text = modifiedDictation.replacingCharacters(in: range, with: word)
    }
        
    //------------------------------------------------------
    //MARK:- keyboard will change frame notification
    
    @objc func keyboardNotification(notification: NSNotification) {

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
    
    private func dismissKeyboard(){
        
        whiteBackground.alpha       = 0
        correctedWordTextField.resignFirstResponder()
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let modifiedWord = textField.text {
            setWordAtRange(with: modifiedWord, in: selectedWordRange)
        }
        
        dismissKeyboard()
        return true
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        
        if let modifiedWord = correctedWordTextField.text {
            setWordAtRange(with: modifiedWord, in: selectedWordRange)
        }
        
        AudioServicesPlaySystemSound(1156)
        dismissKeyboard()
    }

}

