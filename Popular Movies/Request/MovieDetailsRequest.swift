//
//  MovieDetailsRequest.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 26.12.2020.
//

import Foundation

struct MovieDetailsRequest: Request {
    var path: String
    var additionalParams: [String : String]?
}

struct MovieDetailsResponse: Decodable {
    let originalTitle: String
    let overview: String
    let posterPath: String
    let voteCount: Int

    private enum CodingKeys: String, CodingKey {
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case voteCount = "vote_count"
    }
}
