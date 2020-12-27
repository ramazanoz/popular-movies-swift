//
//  ViewController.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 26.12.2020.
//

import UIKit

class MovieListViewController: UIViewController {
    @IBOutlet weak var movieListCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!

    private let gridFlowLayout = GridFlowLayout()
    private let listFlowLayout = ListFlowLayout()
    private var filteredMovies: [Movie] = []

    private var isGridLayoutSelected = true {
        didSet {
            let layout = isGridLayoutSelected ? gridFlowLayout : listFlowLayout
            UIView.animate(withDuration: 0.3) { 
                self.movieListCollectionView.collectionViewLayout.invalidateLayout()
                self.movieListCollectionView.setCollectionViewLayout(layout, animated: true)
            }
            
            self.updateNavigationBarButton()
        }
    }
    
    var viewModel = MovieListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI()
        self.viewModel.load()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.movieListCollectionView.reloadItems(at: self.movieListCollectionView.indexPathsForVisibleItems)
    }

    func updateUI() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = self.viewModel.navigationTitle()
        self.movieListCollectionView.setCollectionViewLayout(self.gridFlowLayout, animated: false)

        self.updateNavigationBarButton()
        movieListCollectionView.dataSource = self
        movieListCollectionView.delegate = self
        searchBar.delegate = self
    }
    
    func updateNavigationBarButton() {
        if let img = UIImage(systemName: isGridLayoutSelected ? "rectangle.grid.2x2" : "list.dash") {
            img.withRenderingMode(UIImage.RenderingMode.automatic)
            let rightBarButtonItem = UIBarButtonItem(image: img, style: UIBarButtonItem.Style.plain, target: self, action: #selector(gridButtonTapped))
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    @objc func gridButtonTapped() {
        self.isGridLayoutSelected = !self.isGridLayoutSelected
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
            case .data:
                self.filterMovies()
                self.movieListCollectionView.reloadData()
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

extension MovieListViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredMovies.count == 0 ? 0 : self.filteredMovies.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == self.filteredMovies.count {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "loadMore", for: indexPath)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieListCell", for: indexPath) as! MovieListCell
        let movie = self.filteredMovies[indexPath.row]
        
        let urlString = "https://image.tmdb.org/t/p/w200\(movie.posterPath)"
        if let url = URL(string: urlString) {
            // TODO : CACHE
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            guard let _ = self else { return }
                            cell.moviePosterImageView.image = image
                        }
                    }
                }
            }
        }
        
        if movie.favorited {
            if let image = UIImage(systemName: "star.fill") {
                cell.favoritedImageView.image = image
            }
            
            cell.favoritedImageView.isHidden = false
        } else {
            cell.favoritedImageView.isHidden = true
        }
        
        cell.movieTitleLabel.text = movie.originalTitle
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.filteredMovies.count {
            self.viewModel.load()
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsController = storyboard.instantiateViewController(withIdentifier: "movieDetails") as? MovieDetailsViewController {
            detailsController.viewModel = MovieDetailsViewModel(selectedMovie: self.filteredMovies[indexPath.row])
            self.navigationController!.pushViewController(detailsController, animated: true)
        }
    }
}

extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterMovies()
    }
    
    func filterMovies() {
        if let searchText = self.searchBar.searchTextField.text {
            self.filteredMovies = self.viewModel.movies.filter({$0.originalTitle.lowercased().prefix(searchText.count) == searchText.lowercased()})
        } else {
            self.filteredMovies = self.viewModel.movies
        }
        
        self.movieListCollectionView.reloadData()
    }
}

