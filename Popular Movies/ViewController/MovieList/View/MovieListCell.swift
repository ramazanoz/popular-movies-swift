//
//  MovieListCell.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 26.12.2020.
//

import UIKit

class MovieListCell: UICollectionViewCell {
    @IBOutlet var moviePosterImageView: UIImageView!
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var favoritedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 12.0
        contentView.layer.masksToBounds = true
    }
}
