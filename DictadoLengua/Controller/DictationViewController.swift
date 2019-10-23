//
//  ViewController.swift
//  DictadoLengua
//
//  Created by Daniel Alesanco on 18/10/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit

class DictationViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet var dictadoTextView: UITextView!
    @IBOutlet var whiteBackground: UIImageView!
    @IBOutlet var correctedWordTextField: UITextField!
    @IBOutlet var correctedWordUIView: UIView!
    @IBOutlet var correctedWordHeightConstraint:  NSLayoutConstraint!

    let dictado = "Todas las tardes, a la salida de la escuela, los niños se habían acostumbrado a ir a jugar al jardín del gigante. Era un jardín grande y hermoso, cubierto de verde y suave césped. Dispersas sobre la hierba brillaban bellas flores como estrellas, y había una docena de melocotones que, en primavera, se cubrían de delicados capullos rosados, y en otoño daban sabroso fruto. \n\nLos pájaros se posaban en los árboles y cantaban tan deliciosamente que los niños interrumpían sus juegos para escucharlos."
    
    var tildeDictation = false
    var bvDictation = false
    var llyDictation = false
    var gjDictation = false
    var hDictation = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(tildeDictation)
        print(bvDictation)
        
        whiteBackground.alpha = 0
        correctedWordUIView.alpha = 0
        
        correctedWordTextField.delegate      = self

        // Add notification for keyboard heigth change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification,object:nil)
        
        
        // Add tap gesture to dismiss keyboard when user tap on the view controller (out of the keyboard)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnTextView(_:)))
        dictadoTextView.addGestureRecognizer(tapGesture)
        
        let dictadoWithoutAccent = removeAcent(from: dictado)
        
        let dictadoWithoutAccentWithRandomBV = randomBV(in: dictadoWithoutAccent)
        
        let dictadoWithFormat = formatDictado(dictadoWithoutAccentWithRandomBV)
        
        dictadoTextView.attributedText = dictadoWithFormat
        dictadoTextView.isEditable = false
        dictadoTextView.isSelectable = false
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // user tapped on textView.
    // Select word tapped and shows it on label
    @objc private final func tapOnTextView(_ tapGesture: UITapGestureRecognizer){
        
        whiteBackground.alpha = 0.8
        correctedWordUIView.alpha = 1

        let point = tapGesture.location(in: dictadoTextView)
        if let detectedWord = getWordAtPosition(point) {
            correctedWordTextField.text = detectedWord
        }
    }
    
    ///////////////////////////////////////////
    //MARK:- keyboard Notification
    
    @objc func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame!.origin.y
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.correctedWordHeightConstraint.constant = 50 //heigth of the message view when it's on the bottom side

            } else {
                self.correctedWordHeightConstraint?.constant = endFrame?.size.height ?? 50
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: .curveLinear,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    
    ////////////////////////////////////////////
    //MARK:- dismiss keyboard
    
    // dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // gets the word closest to user tapped point
    private func getWordAtPosition(_ point: CGPoint) -> String?{
    if let textPosition = dictadoTextView.closestPosition(to: point)
    {
        if let range = dictadoTextView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1))
      {
        return dictadoTextView.text(in: range)
      }
    }
    return nil
        
    }
    
    
    // returns a dictado without accents
    func removeAcent(from dictado : String) -> String {
        
        return  dictado.folding(options: .diacriticInsensitive, locale: .current)
        
    }
    
    // returns a dictado without "b" and "v" added randomly
    func randomBV(in dictado : String) -> String {
        
        var result = ""
        
        for char in dictado {
            if char == "b" || char == "v" {
                
               if Bool.random() {
                    result.append("b")

                } else {
                     result.append("v")
                }
                
            }
            else {
                result.append(char)
            }
        }
        
        return  result
        
    }
    
    
    
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        view.endEditing(true)

    }

}

