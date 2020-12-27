//
//  MovieListViewModelProtocol.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 27.12.2020.
//

import Foundation

enum MovieDetailsUpdate {
    case networkOperationStarted
    case networkOperationEnded
    case errorOccurred(message: String)
    case data(movieDetails: MovieDetailsResponse)
}

protocol MovieDetailsViewModelProtocol {
    var updateViewHandler: ((MovieDetailsUpdate) -> Void)? {get set}
}
