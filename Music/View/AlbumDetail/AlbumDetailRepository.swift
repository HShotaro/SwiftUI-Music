//
//  AlbumDetailRepository.swift
//  Music
//
//  Created by Shotaro Hirano on 2021/09/02.
//

import Foundation
import Combine

protocol AlbumDetailRepository {
    func fetchModel(for albumID: String) -> AnyPublisher<AlbumDetailModel, Error>
}

struct AlbumDetailDataRepository: AlbumDetailRepository {
    func fetchModel(for albumID: String) -> AnyPublisher<AlbumDetailModel, Error> {
        return APIManager.shared.getAlbumDetailModel(for: albumID)
    }
}

fileprivate extension APIManager {
    func getAlbumDetailModel(for albumID: String) -> AnyPublisher<AlbumDetailModel, Error> {
        return APIManager.createRequest(path: "/albums/\(albumID)", type: .GET)
            .flatMap { request in
                URLSession.shared.dataTaskPublisher(for: request)
                .tryMap() { element -> AlbumDetailModel in
                    guard let response = element.response as? HTTPURLResponse else {
                        throw APIError.failedToGetData
                    }
                    guard response.statusCode < 500 else {
                        print("Status Code\(response.statusCode)")
                        throw APIError.serverError
                    }
                    guard response.statusCode < 400 else {
                        print("Status Code\(response.statusCode)")
                        throw APIError.clientError
                    }
                    do {
                        let result = try JSONDecoder().decode(AlbumDetailResponse.self, from: element.data)
                        let model = AlbumDetailModel(rawModel: result)
                        return model
                    }
                    catch {
                        throw error
                    }
                }
        }.eraseToAnyPublisher()
    }
}

