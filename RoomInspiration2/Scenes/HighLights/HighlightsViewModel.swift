import Foundation
import SwiftUI

struct PexelsResponse: Codable {
    let photos: [PexelsPhoto]
}

struct PexelsPhoto: Codable, Identifiable {
    let id: Int
    let photographer: String
    let width: Int
    let height: Int
    let averageColorHex: String?
    let alt: String?
    let url: URL
    let src: Source

    struct Source: Codable {
        let medium: URL
        let large: URL
    }

    enum CodingKeys: String, CodingKey {
        case id, photographer, width, height, alt, url, src
        case averageColorHex = "avg_color"
    }

    var aspectRatio: CGFloat {
        CGFloat(width) / CGFloat(max(height, 1))
    }
}

struct PhotoBlock: Identifiable {
    let id: Int
    let photos: [PexelsPhoto]
}

@MainActor
@Observable
final class HighlightsViewModel {

    var criteria = SearchCriteria()

    private(set) var photos: [PexelsPhoto] = []
    private(set) var blocks: [PhotoBlock] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    func toggle(_ room: RoomType) {
        criteria.room = criteria.room == room ? nil : room
    }

    func toggle(_ style: DecorStyle) {
        criteria.style = criteria.style == style ? nil : style
    }

    func toggle(_ color: PhotoColor) {
        criteria.color = criteria.color == color ? nil : color
    }

    func clearFilters() {
        criteria = SearchCriteria()
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        let request = Self.makeRequest(for: criteria)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Pexels returned \(http.statusCode)"])
            }
            let decoded = try JSONDecoder().decode(PexelsResponse.self, from: data)
            guard !Task.isCancelled else { return }
            photos = decoded.photos
            blocks = Self.makeBlocks(from: decoded.photos)
            errorMessage = nil
        } catch is CancellationError {
        } catch let error as URLError where error.code == .cancelled {
        } catch {
            errorMessage = error.localizedDescription
            photos = []
            blocks = []
        }
    }

    static func makeRequest(for criteria: SearchCriteria, perPage: Int = 30) -> URLRequest {
        var components = URLComponents(string: "https://api.pexels.com/v1/search")!
        var items = [
            URLQueryItem(name: "query", value: criteria.pexelsQuery),
            URLQueryItem(name: "per_page", value: String(perPage)),
        ]
        if let color = criteria.color {
            items.append(URLQueryItem(name: "color", value: color.rawValue))
        }
        components.queryItems = items

        var request = URLRequest(url: components.url!)
        request.setValue(Env.apiKey, forHTTPHeaderField: "Authorization")
        return request
    }

    static func makeBlocks(from photos: [PexelsPhoto], columns: Int = 2, firstRows: Int = 3, otherRows: ClosedRange<Int> = 3...6) -> [PhotoBlock] {
        var blocks: [PhotoBlock] = []
        var start = 0
        while start < photos.count {
            let rows = blocks.isEmpty ? firstRows : Int.random(in: otherRows)
            let end = min(start + rows * columns, photos.count)
            blocks.append(PhotoBlock(id: blocks.count, photos: Array(photos[start..<end])))
            start = end
        }
        return blocks
    }
}
