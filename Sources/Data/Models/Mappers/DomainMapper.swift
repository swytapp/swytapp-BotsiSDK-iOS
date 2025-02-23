//
//  DomainMapper.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

import Foundation

protocol DomainMapper {
    associatedtype DomainModel
    associatedtype DTOResponseModel
    associatedtype DTORequestModel: Encodable
    associatedtype Parameters
    
    func toDTO(from model: Parameters) -> DTORequestModel
    func toDomain(from dto: DTOResponseModel) -> DomainModel
}

extension Encodable {
    func toData() throws -> Data {
        do {
            return try JSONEncoder().encode(self)
        } catch (let error) {
            throw BotsiHTTPEnecodingError.encodingFailed(error.localizedDescription)
        }
    }
}
