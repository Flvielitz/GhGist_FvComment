//
//  QRCodeReaderProtocol.swift
//  GhGist_FvComment
//
//  Created by Philliph on 13/07/18.
//  Copyright © 2018 Philliph. All rights reserved.
//

import UIKit

protocol QRCodeReaderProtocol {
    
    func startReading(completion: @escaping (String) -> Void)
    func stopReading()
    var videoPreview : CALayer { get }
    
}
