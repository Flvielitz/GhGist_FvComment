//
//  RoundShadowViewBezier.swift
//  GhGist_FvComment
//
//  Created by Philliph on 15/07/18.
//  Copyright © 2018 Philliph. All rights reserved.
//

import UIKit

class RoundShadowViewBezier : UIView {
    
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 15.0 //15
    
    private var fillColor: UIColor = .black // the color applied to the shadowLayer, rather than the view's backgroundColor
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .clear
        
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.5
            shadowLayer.shadowRadius = 5
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
        
        
    }
}
