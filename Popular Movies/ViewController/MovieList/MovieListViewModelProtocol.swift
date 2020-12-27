//
//  MovieListViewModelProtocol.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 26.12.2020.
//

import Foundation

enum MovieListViewUpdate {
    case networkOperationStarted
    case networkOperationEnded
    case errorOccurred(message: String)
    case data(movieList: [Movie])
}

protocol MovieListViewModelProtocol {
    var updateViewHandler: ((MovieListViewUpdate) -> Void)? {get set}
}
