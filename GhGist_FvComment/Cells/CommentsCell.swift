//
//  CommentsCell.swift
//  GhGist_FvComment
//
//  Created by Philliph on 14/07/18.
//  Copyright © 2018 Philliph. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {

    @IBOutlet weak var labelBody: UILabel!
    @IBOutlet weak var labelCreatedAt: UILabel!
    @IBOutlet weak var labelUser: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.labelBody.textColor = .white
        self.labelUser.textColor = .white
        self.labelCreatedAt.textColor = .white
        
        self.layer.cornerRadius = 13
        self.backgroundColor = .CustomDarkTwo()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 0.3
        self.clipsToBounds = false
        self.layer.shadowRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
