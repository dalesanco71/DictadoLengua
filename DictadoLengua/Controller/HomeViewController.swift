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
    // MARK: - Outlet references

    @IBOutlet weak var bvButton:    UIButton!
    @IBOutlet weak var llyButton:   UIButton!
    @IBOutlet weak var tildeButton: UIButton!
    @IBOutlet weak var gjButton:    UIButton!
    @IBOutlet weak var hButton:     UIButton!
    
    
    //------------------------------------------------------
    // MARK: - Global variables

    private var tildeDictation  = false
    private var bvDictation     = false
    private var llyDictation    = false
    private var gjDictation     = false
    private var hDictation      = false
    
    
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
            
            destinationVC.tildeDictation    = tildeDictation
            destinationVC.bvDictation       = bvDictation
            destinationVC.llyDictation      = llyDictation
            destinationVC.gjDictation       = gjDictation
            destinationVC.hDictation        = hDictation
                        
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

    @IBAction func bvButtonTapped(_ sender: UIButton) {
        
        bvDictation = !bvDictation
        
        let titleColor = bvDictation ? UIColor.red : UIColor.blue
        bvButton.setTitleColor(titleColor, for: .normal)
    }
    
    @IBAction func llyButtonTapped(_ sender: UIButton) {
        
        llyDictation = !llyDictation
        
        let titleColor = llyDictation ? UIColor.red : UIColor.blue
        llyButton.setTitleColor(titleColor, for: .normal)
    }
    
    @IBAction func tildeButtonTapped(_ sender: UIButton) {
        
        tildeDictation = !tildeDictation
        
        let titleColor = tildeDictation ? UIColor.red : UIColor.blue
        tildeButton.setTitleColor(titleColor, for: .normal)
    }
    
    @IBAction func gjButtonTapped(_ sender: UIButton) {
       
        gjDictation = !gjDictation
        
        let titleColor = gjDictation ? UIColor.red : UIColor.blue
        gjButton.setTitleColor(titleColor, for: .normal)
    }
    
    
    @IBAction func hButtonTapped(_ sender: UIButton) {
        
        hDictation = !hDictation
        
        let titleColor = hDictation ? UIColor.red : UIColor.blue
        hButton.setTitleColor(titleColor, for: .normal)
    }
    
}
