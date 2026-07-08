import Foundation

public struct LsofListener: Equatable {
    public let command: String
    public let pid: Int
    public let user: String
    public let fileDescriptor: String
    public let family: String
    public let endpoint: String
    public let address: String
    public let port: Int
}

public enum LsofListenParser {
    public static func parse(_ output: String) -> [LsofListener] {
        output
            .split(separator: "\n", omittingEmptySubsequences: true)
            .dropFirst()
            .compactMap(parseLine)
    }

    private static func parseLine(_ line: Substring) -> LsofListener? {
        let parts = line.split(separator: " ", maxSplits: 8, omittingEmptySubsequences: true)
        guard parts.count >= 9, let pid = Int(parts[1]) else { return nil }
        guard let endpoint = parts[8].split(separator: " ", maxSplits: 1).first else { return nil }
        guard let parsedEndpoint = parseEndpoint(String(endpoint)) else { return nil }

        return LsofListener(
            command: String(parts[0]),
            pid: pid,
            user: String(parts[2]),
            fileDescriptor: String(parts[3]),
            family: String(parts[4]),
            endpoint: String(endpoint),
            address: parsedEndpoint.address,
            port: parsedEndpoint.port
        )
    }

    private static func parseEndpoint(_ endpoint: String) -> (address: String, port: Int)? {
        if endpoint.hasPrefix("[") {
            guard let closeBracket = endpoint.firstIndex(of: "]") else { return nil }
            let address = String(endpoint[endpoint.index(after: endpoint.startIndex)..<closeBracket])
            let remainder = endpoint[endpoint.index(after: closeBracket)...]
            guard remainder.hasPrefix(":"), let port = Int(remainder.dropFirst()) else { return nil }
            return (address, port)
        }

        guard let separator = endpoint.lastIndex(of: ":") else { return nil }
        let address = String(endpoint[..<separator])
        let portText = endpoint[endpoint.index(after: separator)...]
        guard let port = Int(portText) else { return nil }
        return (address, port)
    }
}

public struct DockerPublishedPort: Equatable, Hashable {
    public let hostAddress: String
    public let hostPort: Int
}

public enum DockerPublishedPortParser {
    public static func parse(_ value: String) -> [DockerPublishedPort] {
        value
            .split(separator: ",", omittingEmptySubsequences: true)
            .compactMap { parseMapping(String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
    }

    private static func parseMapping(_ value: String) -> DockerPublishedPort? {
        guard let arrow = value.range(of: "->") else { return nil }
        let hostSide = String(value[..<arrow.lowerBound])

        if hostSide.hasPrefix("[") {
            guard let closeBracket = hostSide.firstIndex(of: "]") else { return nil }
            let address = String(hostSide[hostSide.index(after: hostSide.startIndex)..<closeBracket])
            let remainder = hostSide[hostSide.index(after: closeBracket)...]
            guard remainder.hasPrefix(":"), let port = Int(remainder.dropFirst()) else { return nil }
            return DockerPublishedPort(hostAddress: address, hostPort: port)
        }

        guard let separator = hostSide.lastIndex(of: ":") else { return nil }
        let address = String(hostSide[..<separator])
        let portText = hostSide[hostSide.index(after: separator)...]
        guard let port = Int(portText) else { return nil }
        return DockerPublishedPort(hostAddress: address, hostPort: port)
    }
}
