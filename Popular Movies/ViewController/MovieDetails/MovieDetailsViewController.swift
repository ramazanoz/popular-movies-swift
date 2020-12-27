//
//  MovieDetailsViewController.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 27.12.2020.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
    @IBOutlet weak var voteCount: UILabel!

    var viewModel: MovieDetailsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI()
        self.viewModel.load()
        self.bindViewModel()
    }
    
    func updateUI() {
        self.navigationItem.title = self.viewModel.navigationTitle()
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        self.updateNavigationBarButton()
    }
    
    func updateNavigationBarButton() {
        if let img = UIImage(systemName: self.viewModel.movie.favorited ? "star.fill" : "star") {
            img.withRenderingMode(UIImage.RenderingMode.automatic)
            let rightBarButtonItem = UIBarButtonItem(image: img, style: UIBarButtonItem.Style.plain, target: self, action: #selector(gridButtonTapped))
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    @objc func gridButtonTapped() {
        self.viewModel.setFavorite(isFavorite: !self.viewModel.movie.favorited)
        
        let userDefaults = UserDefaults.standard
        
        if var fav = userDefaults.array(forKey: "favoritedMovies") as? [Int] {
            if self.viewModel.movie.favorited {
                fav.append(self.viewModel.movie.id)
            } else {
                if let index = fav.firstIndex(of: self.viewModel.movie.id) {
                    fav.remove(at: index)
                }
            }
            
            userDefaults.setValue(fav, forKey: "favoritedMovies")
        } else {
            userDefaults.setValue([self.viewModel.movie.id], forKey: "favoritedMovies")
        }
        
        self.updateNavigationBarButton()
    }
    
    private func bindViewModel() {
        self.viewModel.updateViewHandler = { [unowned self] update in
            switch update {
            case .networkOperationStarted:
                self.showSpinner()
            case .networkOperationEnded:
                self.dismissSpinner()
                break
            case .errorOccurred(let message):
                print(message)
            case .data(movieDetails: let movieDetails):
                self.movieTitle.text = movieDetails.originalTitle
                self.movieDescription.text = movieDetails.overview
                self.voteCount.text = "Votes : \(movieDetails.voteCount)"
                
                let urlString = "https://image.tmdb.org/t/p/w200\(movieDetails.posterPath)"
                guard let url = URL(string: urlString) else {
                    return
                }
                
                // TODO : CACHE
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                guard let strongSelf = self else { return }
                                strongSelf.moviePoster.image = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showSpinner() {
        Spinner.show()
    }
    
    private func dismissSpinner() {
        Spinner.dismiss()
    }
}
