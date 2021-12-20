//
//  HBWebImageProtocol.swift
//  HBWebImage
//
//  Created by 徐浩博 on 2021/11/22.
//

import Foundation

enum HBWebImageProtocolError: Error {
    case HBWebImageProtocolURLError
    case HBWebImageProtocolDataFetchError
}

protocol HBWebImageProtocol {
    func fetchData(url: URL, completionHandler: ((Result<Data, HBWebImageProtocolError>) -> Void)?)
}

extension HBWebImageProtocol {
    func fetchData(url: URL, completionHandler: ((Result<Data, HBWebImageProtocolError>) -> Void)?) {
        WebImageQueue.async {
            do {
                let data = try Data(contentsOf: url)
                completionHandler?(.success(data))
            } catch {
                completionHandler?(.failure(.HBWebImageProtocolDataFetchError))
            }
        }
    }
}
