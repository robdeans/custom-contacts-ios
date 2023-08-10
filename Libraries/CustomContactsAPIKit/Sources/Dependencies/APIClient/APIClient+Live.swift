//
//  APIClient+Live.swift
//  CustomContactsAPIKit
//
//  Created by full_name on date_markup.
//  Copyright © year_markup Fueled. All rights reserved.
//

import Dependencies
import Foundation
import CustomContactsHelpers

final class APIClientLive: APIClient {
	@Dependency(\.apiKitEnvironment) var apiKitEnvironment

	func request<Response>(_ request: APIRequest<Response>) async throws -> Response where Response: Decodable {
		do {
			let urlRequest = try request.makeRequest(using: apiKitEnvironment.environment.baseURL)
			// TODO: add shared headers
			let (data, _) = try await URLSession.shared.data(for: urlRequest)
			return try request.decoder.decode(Response.self, from: data)
		} catch {
			LogError(error.localizedDescription)
			throw error
		}
	}
}

extension APIRequest {
	fileprivate func makeRequest(using baseURL: URL) throws -> URLRequest {
		guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
			throw URLError(.badURL)
		}

		components.path = path.isEmpty ? "" : "/" + path
		components.queryItems = query?.compactMap { URLQueryItem(name: $0.0, value: $0.1) }

		guard let url = components.url else {
			throw URLError(.unsupportedURL)
		}

		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = method.stringValue

		if case let .post(data) = method {
			urlRequest.httpBody = data
		} else if case let .put(data) = method {
			urlRequest.httpBody = data
		}

		headers?.forEach { key, value in
			urlRequest.setValue(value.description, forHTTPHeaderField: key)
		}
		return urlRequest
	}
}
