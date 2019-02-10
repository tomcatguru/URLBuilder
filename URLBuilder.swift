//
//  URLBuilder.swift
//  SearchingCarModel
//
//  Created by 이강희 on 09/02/2019.
//  Copyright © 2019 tomcatguru. All rights reserved.
//

import UIKit
import Foundation

protocol URLBuildableType {}

extension URL: URLBuildableType {}
extension URLComponents: URLBuildableType {}
extension String: URLBuildableType {}

final class URLBuilder<T: URLBuildableType> {
    //MARK - private variables
    private var isHttps: Bool = true
    private var scheme: String?
    private var host: String?
    private var path: String?
    private var keyValues : [String : String] = [:]
    
    //MARK - public funtions
    @discardableResult
    func withScheme(_ scheme: String) -> URLBuilder<T> {
        self.isHttps = false
        self.scheme = scheme
        return self
    }
    
    @discardableResult
    func withHttp() -> URLBuilder<T> {
        self.isHttps = false
        return self
    }
    
    @discardableResult
    func withHost(_ host: String) -> URLBuilder<T> {
        self.host = host
        return self
    }
    
    @discardableResult
    func withPath(_ path: String) -> URLBuilder<T> {
        self.path = path
        return self
    }
    
    @discardableResult
    func withParam(_ key: String, _ value: String) -> URLBuilder<T> {
        self.keyValues[key] = value
        return self
    }
    
    @discardableResult
    func withParams(_ keyValues: [String : String]) -> URLBuilder<T> {
        self.keyValues = keyValues
        return self
    }
    
    //MARK - private funtions
    private func protocolString() -> String {
        return self.protocolOnlyString() + "://"
    }
    
    private func protocolOnlyString() -> String {
        if let customScheme = self.scheme, !isHttps {
            return customScheme
        } else {
            return isHttps ? "https" : "http"
        }
    }
    
    private func toUrlComponents() -> URLComponents? {
        guard let host = self.host, let path = self.path else {
            return nil
        }
        
        var result = URLComponents()
        result.scheme = self.protocolOnlyString()
        result.host = host
        result.path = path
        
        result.queryItems = [URLQueryItem]()
        for (key, value) in self.keyValues.reversed() {
            result.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        
        return result
    }
    
    private func toString() -> String? {
        guard let host = self.host, let path = self.path else {
            return nil
        }
        var modifiedPath = path
        
        if host.count == 0 {
            modifiedPath = path.deletingPrefix("/")
        }
        
        var result = ""
        result.append(self.protocolString())
        result.append(host)
        result.append(modifiedPath + "?")
        
        var keyIndex: UInt = 1
        for (key, value) in self.keyValues.reversed() {
            let stringFormat = (self.keyValues.count == keyIndex) ? "%@=%@" : "%@=%@&"
            result.append(String(format: stringFormat, key, value))
            keyIndex += 1
        }
        
        return result
    }
}

extension URLBuilder where T == URL {
    func build() -> T? {
        guard let result = self.toString() else {
            return nil
        }
        return URL(string: result)
    }
}

extension URLBuilder where T == URLComponents {
    func build() -> T? {
        return self.toUrlComponents()
    }
}

extension URLBuilder where T == String {
    func build() -> T? {
        return self.toString()
    }
}


