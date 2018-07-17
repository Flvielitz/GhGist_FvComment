//
//  AddCommentVC.swift
//  GhGist_FvComment
//
//  Created by Philliph on 14/07/18.
//  Copyright © 2018 Philliph. All rights reserved.
//

import UIKit

protocol AddCommentProt {
    func receivedCommentText(text : String )
}

class AddCommentVC: UIViewController {

    @IBOutlet weak var viewShadow: RoundShadowViewBezier!
    @IBOutlet weak var textFieldC: UITextView!
    @IBOutlet weak var btnPostC: UIButton!
    
    var delegate: AddCommentProt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .CustomDarkOne()
        self.title = "Create Comment"
        btnPostC.addTarget(self, action: #selector(confirmNewComment(_:)), for: .touchUpInside)
        textFieldC.setPreferences()
        
        btnPostC.backgroundColor = .colorFromRGB(red: 0, green: 122, blue: 255 )
        btnPostC.layer.cornerRadius = 8
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let auth = GitAPI.sharedInstance.requiresAuth()
        
        //We need to ask for gist permission to comment!
        if auth {
            self.presentAlertCancelWithCompletion("Alert", message: "You need to log in to be able to comment in a gist") { action in
                guard let title = action.title else { return }
                if title.first == "O" {
                    GitAPI.sharedInstance.loadToken(viewController: self )
                }
            }}
        else {
            //Auto-Trigger
            textFieldC.becomeFirstResponder()
        }
    }
    
    @IBAction func confirmNewComment(_ sender : UIButton?) {
        
        if self.textFieldC.text.count > 0 {
            GitAPI.sharedInstance.clearURLHandler()
            delegate?.receivedCommentText(text: self.textFieldC.text )
            navigationController?.popViewController(animated: true)
        }
        else {
            presentAlert("Warning", message: "You need to type something to create a comment")
        }
    }
}
