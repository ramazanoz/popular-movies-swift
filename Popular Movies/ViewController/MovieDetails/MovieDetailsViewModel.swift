//
//  MovieDetailsViewModel.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 27.12.2020.
//

import Foundation

class MovieDetailsViewModel: MovieDetailsViewModelProtocol {
    var updateViewHandler: ((MovieDetailsUpdate) -> Void)?
    public private(set) var movie: Movie
    
    init(selectedMovie: Movie) {
        self.movie = selectedMovie
    }
    
    func navigationTitle() -> String {
        return "Content Details"
    }
    
    func updateView(update: MovieDetailsUpdate) {
        DispatchQueue.main.async {
            self.updateViewHandler?(update)
        }
    }
    
    func setFavorite(isFavorite: Bool) {
        self.movie.favorited = isFavorite
    }
    
    func load() {
        let req = MovieDetailsRequest(path: "\(movie.id)")
        self.updateView(update: .networkOperationStarted)
        
        NetworkManager.sharedInstance.pushRequest(req, completion: { [self] (response:PMResponse<MovieDetailsResponse>?) in
            self.updateView(update: .networkOperationEnded)

            switch response {
            case let .success(data):
                self.updateView(update: .data(movieDetails: data))
            case .failure(_):
                self.updateView(update: .errorOccurred(message: "Error occured"))
            case .none:
                self.updateView(update: .errorOccurred(message: "Error occured"))
            }
        })
    }
}
