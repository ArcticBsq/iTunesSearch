//
//  CustomCollectionCell.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 26.09.2021.
//

import UIKit

class CustomCollectionCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .black
        self.layer.cornerRadius = 10
        imageView.layer.cornerRadius = 10
        containerView.layer.cornerRadius = 10
        activityIndicator.hidesWhenStopped = true
    }

}
