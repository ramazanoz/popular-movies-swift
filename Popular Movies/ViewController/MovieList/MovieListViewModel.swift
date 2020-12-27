//
//  MovieListViewModel.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 26.12.2020.
//

import Foundation

class MovieListViewModel: MovieListViewModelProtocol {
    var updateViewHandler: ((MovieListViewUpdate) -> Void)?
    private var currentPageId = 1
    private var favoritedMovies: [Int] = []
    public var movies: [Movie] = []

    init() {
        let userDefaults = UserDefaults.standard
        if let fav = userDefaults.array(forKey: "favoritedMovies") as? [Int] {
            self.favoritedMovies = fav
        }
    }
    
    func navigationTitle() -> String {
        return "Contents"
    }
    
    func updateView(update: MovieListViewUpdate) {
        DispatchQueue.main.async {
            self.updateViewHandler?(update)
        }
    }
    
    func load() {
        let req = MovieListRequest(pageId: currentPageId)
        self.updateView(update: .networkOperationStarted)
        
        NetworkManager.sharedInstance.pushRequest(req, completion: { [self] (response:PMResponse<MovieListResponse>?) in
            self.updateView(update: .networkOperationEnded)

            switch response {
            case let .success(data):
                if self.favoritedMovies.count > 0 {
                    for item in data.movies {
                        if self.favoritedMovies.contains(item.id) {
                            item.favorited = true
                        }
                    }
                }
                
                self.movies += data.movies
                
                self.updateView(update: .data(movieList: self.movies))
                currentPageId = currentPageId + 1
            case .failure(_):
                self.updateView(update: .errorOccurred(message: "Error occured"))
            case .none:
                self.updateView(update: .errorOccurred(message: "Error occured"))
            }
        })
    }
}
