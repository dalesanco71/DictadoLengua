//
//  HomeViewController.swift
//  DictadoLengua
//
//  Created by Daniel Alesanco on 23/10/2019.
//  Copyright © 2019 Daniel Alesanco. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    //------------------------------------------------------
    // MARK: - Global variables

    private var dictationOptions = Set<String>()
    
    //------------------------------------------------------
    // MARK: - View did load

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //------------------------------------------------------
    // MARK: - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "homeToDictationSegue" {
            
            let destinationVC = segue.destination as! DictationViewController
            destinationVC.dictationOptions  = dictationOptions
        }
    }
    
    //------------------------------------------------------
    // MARK: - Dictation Selection button action

    @IBAction func cameraButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func folderButtonTapped(_ sender: UIButton) {
    }
    
    //------------------------------------------------------
    // MARK: - Dictation options button action

    @IBAction func dictationOptionButtonTapped(_ sender: UIButton) {

        sender.isSelected = !sender.isSelected

        if let buttonText = sender.titleLabel?.text {
           
            if sender.isSelected {
                dictationOptions.insert(buttonText)
                
            } else {
                dictationOptions.remove(buttonText)
            }
        }
    }
}
