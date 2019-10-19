//
//  ViewController.swift
//  DictadoLengua
//
//  Created by Daniel Alesanco on 18/10/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var dictadoTextView: UITextView!
    @IBOutlet weak var palabraTextField: UITextField!
    
    let dictado = "Todas las tardes, a la salida de la escuela, los niños se habían acostumbrado a ir a jugar al jardín del gigante. Era un jardín grande y hermoso, cubierto de verde y suave césped. Dispersas sobre la hierba brillaban bellas flores como estrellas, y había una docena de melocotones que, en primavera, se cubrían de delicados capullos rosados, y en otoño daban sabroso fruto. \n\nLos pájaros se posaban en los árboles y cantaban tan deliciosamente que los niños interrumpían sus juegos para escucharlos."
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnTextView(_:)))
        dictadoTextView.addGestureRecognizer(tapGesture)
        
        let dictadoWithoutAccent = removeAcent(from: dictado)
        
        let dictadoWithoutAccentWithRandomBV = randomBV(in: dictadoWithoutAccent)
        
        let dictadoWithFormat = formatDictado(dictadoWithoutAccentWithRandomBV)
        
        dictadoTextView.attributedText = dictadoWithFormat
        dictadoTextView.isEditable = false
        dictadoTextView.isSelectable = false
        
    }

    // user tapped on textView.
    // Select word tapped and shows it on label
    @objc private final func tapOnTextView(_ tapGesture: UITapGestureRecognizer){

      let point = tapGesture.location(in: dictadoTextView)
      if let detectedWord = getWordAtPosition(point)
      {
        palabraTextField.text = detectedWord
      }
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
    
    
    
    @IBAction func doneBtnPress(_ sender: UIBarButtonItem) {
        
        
    }
    
    @IBAction func checkBtnPressed(_ sender: UIBarButtonItem) {
        
        
    }
}

