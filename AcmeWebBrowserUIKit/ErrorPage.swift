//
//  ErrorPage.swift
//  AcmeWebBrowserUIKit
//
//  Created by Nilay Neeranjun on 3/26/21.
//

import UIKit

class ErrorPage: UIView {
    
    var errorMessage = UILabel()
    var shouldSetupConstraints = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        errorMessage.textAlignment = .center
        errorMessage.lineBreakMode = .byWordWrapping
        errorMessage.numberOfLines = 0
        addSubview(errorMessage)
        errorMessage.translatesAutoresizingMaskIntoConstraints = false
        errorMessage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        errorMessage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        errorMessage.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        errorMessage.sizeToFit()
        errorMessage.center = self.center
    }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
        
  override func updateConstraints() {
    if(shouldSetupConstraints) {
      // AutoLayout constraints
      shouldSetupConstraints = false
    }
    super.updateConstraints()
  }
    


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
