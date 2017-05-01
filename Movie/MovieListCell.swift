//
//  MovieListCell.swift
//  Movie
//
//  Created by Prabhat Kasera on 29/04/17.
//  Copyright © 2017 Prabhat Kasera. All rights reserved.
//

import UIKit

class MovieListCell : UITableViewCell {
    
    @IBOutlet weak var MovieImageView: UIImageView!
    @IBOutlet weak var MovieOverView: UILabel!
    @IBOutlet weak var MovieReleaseDate: UILabel!
    @IBOutlet weak var MovieTitle: UILabel!
    
    func renderDataToCellWith(dataDictionary : NSDictionary) {
        MovieTitle.text = dataDictionary.value(forKey: movie_title) as? String
        MovieReleaseDate.text = dataDictionary.value(forKey: release_date) as? String
        MovieOverView.text = dataDictionary.value(forKey: overview) as? String
    }
    // Render data with the Record model type,
    func renderDataToCellWith(record : Record) {
        MovieImageView.image = UIImage(named: "placeholder")
        MovieTitle.text = record.title!
        MovieReleaseDate.text = record.releaseDate!
        MovieOverView.text = record.overview!
    }
}
