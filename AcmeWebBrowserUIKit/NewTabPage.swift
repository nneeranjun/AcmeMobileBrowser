//
//  NewTab.swift
//  AcmeWebBrowserUIKit
//
//  Created by Nilay Neeranjun on 3/27/21.
//

import UIKit

class NewTabPage: UIView {
    
    var message = UILabel()
    var shouldSetupConstraints = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        message.lineBreakMode = .byWordWrapping
        message.numberOfLines = 0
        addSubview(message)
        message.translatesAutoresizingMaskIntoConstraints = false
        message.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        message.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        message.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        message.sizeToFit()
        message.center = self.center
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
