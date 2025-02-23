//
//  BotsiHttpResponse.swift
//  Botsi
//
//  Created by Vladyslav on 22.02.2025.
//

import Foundation

struct BotsiHTTPResponse<Body> {
    let body: Body
    
    func replaceDecodingTime(start: DispatchTime, end: DispatchTime) -> BotsiHTTPResponse {
        return self
    }
}
