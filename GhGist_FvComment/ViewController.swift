//
//  ViewController.swift
//  GhGist_FvComment
//
//  Created by Philliph on 14/07/18.
//  Copyright © 2018 Philliph. All rights reserved.
//

import UIKit

import OAuthSwift



class ViewController: UIViewController {

    /*
     QR Code ViewController
     */
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var qrCodeVideoPreview: UIView!
    private var videoLayer: CALayer!
    
    var qrCodeReader: QRCodeReaderProtocol = QRCodeReader()
    let git = GitAPI.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoLayer = qrCodeReader.videoPreview
        qrCodeVideoPreview.layer.addSublayer(videoLayer)
        view.backgroundColor = .CustomDarkOne()
        labelTitle.textColor = .white
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoLayer.frame = qrCodeVideoPreview.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        qrCodeReader.startReading { [weak self] qrCode in
            self?.filterQRCodeString(qrCode)
         }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrCodeReader.stopReading()
    }
    
    func filterQRCodeString(_ stringRec : String) {
        //QR Code reads the Gist String and uses the ID part
        let splitString = stringRec.split(separator: "/")
        guard let subString = splitString.last else { return }
        git.createCommentString(gistID : String(subString))
        
        //Move to CommentsList View Controller
        let commentVC = CommentsListVC(nibName: "CommentsListVC", bundle: nil)
        let nav = UINavigationController(rootViewController: commentVC)
        self.present(nav, animated: true, completion: nil)
    }
}


