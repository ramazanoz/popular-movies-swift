//
//  MovieListRequest.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 27.12.2020.
//

import Foundation

struct MovieListRequest: Request {
    var path: String {
        return "popular"
    }
    
    var additionalParams: [String : String]? {
        return ["page": "\(self.pageId)"]
    }
    
    var pageId: Int
}

struct MovieListResponse: Decodable {
    let movies: [Movie]
    let page: Int

    private enum CodingKeys: String, CodingKey {
        case movies = "results"
        case page
    }
}

class Movie: Decodable {
    let id: Int
    let originalTitle: String
    let overview: String
    let posterPath: String
    var favorited: Bool = false

    private enum CodingKeys: String, CodingKey {
        case id
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
    }
}
