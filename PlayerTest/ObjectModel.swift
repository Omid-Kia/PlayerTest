//
//  ObjectModel.swift
//  PlayerTest
//
//  Created by Saeed on 7/2/21.
//

import Foundation

struct ObjectModel: Codable {
    let categories: [Category]
}

// MARK: - Category
struct Category: Codable {
    let name: String
    let videos: [Video]
}

// MARK: - Video
struct Video: Codable {
    let videoDescription: String
    let sources: [String]
    let subtitle: Subtitle
    let thumb, title: String

    enum CodingKeys: String, CodingKey {
        case videoDescription = "description"
        case sources, subtitle, thumb, title
    }
}

enum Subtitle: String, Codable {
    case byBlenderFoundation = "By Blender Foundation"
    case byGarage419 = "By Garage419"
    case byGoogle = "By Google"
}
