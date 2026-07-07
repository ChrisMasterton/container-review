import AppKit
import SwiftUI

struct ContainerSummary: Identifiable, Equatable {
    let id: String
    let shortID: String
    let name: String
    let image: String
    let state: String
    let status: String
    let runningFor: String
    let ports: String
    let labels: [String: String]

    var displayName: String {
        name.isEmpty ? shortID : name
    }

    var composeProject: String? {
        labels["com.docker.compose.project"]
    }

    var composeService: String? {
        labels["com.docker.compose.service"]
    }

    var projectServiceText: String {
        switch (composeProject, composeService) {
        case let (project?, service?):
            return "\(project) / \(service)"
        case let (project?, nil):
            return project
        case let (nil, service?):
            return service
        default:
            return "Standalone"
        }
    }

    var portSummary: String {
        ports.isEmpty ? "-" : ports
    }

    var createdAgeText: String {
        runningFor.isEmpty ? "-" : "Created \(runningFor)"
    }

    var isRunning: Bool {
        state.localizedCaseInsensitiveContains("running")
    }
}

struct DockerPSRecord: Decodable {
    let id: String?
    let image: String?
    let names: String?
    let ports: String?
    let runningFor: String?
    let status: String?
    let state: String?
    let labels: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case image = "Image"
        case names = "Names"
        case ports = "Ports"
        case runningFor = "RunningFor"
        case status = "Status"
        case state = "State"
        case labels = "Labels"
    }

    var summary: ContainerSummary? {
        guard let id, !id.isEmpty else { return nil }
        return ContainerSummary(
            id: id,
            shortID: String(id.prefix(12)),
            name: names ?? "",
            image: image ?? "",
            state: state ?? "",
            status: status ?? "",
            runningFor: runningFor ?? "",
            ports: ports ?? "",
            labels: Self.parseLabels(labels ?? "")
        )
    }

    private static func parseLabels(_ labels: String) -> [String: String] {
        var parsed: [String: String] = [:]
        for label in labels.split(separator: ",", omittingEmptySubsequences: true) {
            let parts = label.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { continue }
            parsed[String(parts[0])] = String(parts[1])
        }
        return parsed
    }
}

struct ContainerDetail: Equatable {
    let fullID: String
    let name: String
    let image: String
    let imageID: String
    let command: String
    let created: String
    let state: String
    let health: String?
    let startedAt: String?
    let finishedAt: String?
    let restartPolicy: String
    let labels: [String: String]
    let ports: [PortMapping]
    let mounts: [MountInfo]
    let networks: [NetworkInfo]

    var shortID: String {
        String(fullID.prefix(12))
    }

    var displayName: String {
        name.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    var composeProject: String? {
        labels["com.docker.compose.project"]
    }

    var composeService: String? {
        labels["com.docker.compose.service"]
    }

    var workingDirectory: String? {
        labels["com.docker.compose.project.working_dir"]
    }

    var isRunning: Bool {
        state.localizedCaseInsensitiveContains("running")
    }

    var stateLabel: String {
        state.isEmpty ? "not running" : state.capitalized
    }
}

struct PortMapping: Identifiable, Equatable {
    let id = UUID()
    let containerPort: String
    let host: String
    let hostPort: String

    var url: URL? {
        guard let port = Int(hostPort), port > 0 else { return nil }
        let hostName = host.isEmpty || host == "0.0.0.0" || host == "::" ? "localhost" : host
        return URL(string: "http://\(hostName):\(port)")
    }

    var displayHost: String {
        host.isEmpty ? "localhost" : host
    }
}

struct MountInfo: Identifiable, Equatable {
    let id = UUID()
    let type: String
    let source: String
    let destination: String
    let mode: String
}

struct NetworkInfo: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let ipAddress: String
    let aliases: [String]
}

struct DockerInspectRecord: Decodable {
    let id: String
    let name: String
    let created: String
    let path: String?
    let args: [String]?
    let image: String
    let config: Config
    let state: State
    let hostConfig: HostConfig?
    let networkSettings: NetworkSettings?
    let mounts: [Mount]

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case created = "Created"
        case path = "Path"
        case args = "Args"
        case image = "Image"
        case config = "Config"
        case state = "State"
        case hostConfig = "HostConfig"
        case networkSettings = "NetworkSettings"
        case mounts = "Mounts"
    }

    struct Config: Decodable {
        let image: String?
        let labels: [String: String]?

        enum CodingKeys: String, CodingKey {
            case image = "Image"
            case labels = "Labels"
        }
    }

    struct State: Decodable {
        let status: String?
        let running: Bool?
        let startedAt: String?
        let finishedAt: String?
        let health: Health?

        enum CodingKeys: String, CodingKey {
            case status = "Status"
            case running = "Running"
            case startedAt = "StartedAt"
            case finishedAt = "FinishedAt"
            case health = "Health"
        }
    }

    struct Health: Decodable {
        let status: String?

        enum CodingKeys: String, CodingKey {
            case status = "Status"
        }
    }

    struct HostConfig: Decodable {
        let restartPolicy: RestartPolicy?

        enum CodingKeys: String, CodingKey {
            case restartPolicy = "RestartPolicy"
        }
    }

    struct RestartPolicy: Decodable {
        let name: String?

        enum CodingKeys: String, CodingKey {
            case name = "Name"
        }
    }

    struct NetworkSettings: Decodable {
        let ports: [String: [PortBinding]?]?
        let networks: [String: Network]?

        enum CodingKeys: String, CodingKey {
            case ports = "Ports"
            case networks = "Networks"
        }
    }

    struct PortBinding: Decodable {
        let hostIP: String?
        let hostPort: String?

        enum CodingKeys: String, CodingKey {
            case hostIP = "HostIp"
            case hostPort = "HostPort"
        }
    }

    struct Network: Decodable {
        let ipAddress: String?
        let aliases: [String]?

        enum CodingKeys: String, CodingKey {
            case ipAddress = "IPAddress"
            case aliases = "Aliases"
        }
    }

    struct Mount: Decodable {
        let type: String?
        let source: String?
        let destination: String?
        let mode: String?

        enum CodingKeys: String, CodingKey {
            case type = "Type"
            case source = "Source"
            case destination = "Destination"
            case mode = "Mode"
        }
    }

    var detail: ContainerDetail {
        let command = ([path].compactMap { $0 } + (args ?? [])).joined(separator: " ")
        return ContainerDetail(
            fullID: id,
            name: name,
            image: config.image ?? "",
            imageID: image,
            command: command,
            created: created,
            state: state.status ?? "",
            health: state.health?.status,
            startedAt: state.startedAt,
            finishedAt: state.finishedAt,
            restartPolicy: hostConfig?.restartPolicy?.name?.isEmpty == false ? hostConfig?.restartPolicy?.name ?? "no" : "no",
            labels: config.labels ?? [:],
            ports: Self.portMappings(from: networkSettings?.ports ?? [:]),
            mounts: mounts.map {
                MountInfo(
                    type: $0.type ?? "-",
                    source: $0.source ?? "-",
                    destination: $0.destination ?? "-",
                    mode: $0.mode ?? "-"
                )
            },
            networks: (networkSettings?.networks ?? [:])
                .map { name, network in
                    NetworkInfo(
                        name: name,
                        ipAddress: network.ipAddress ?? "-",
                        aliases: network.aliases ?? []
                    )
                }
                .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        )
    }

    private static func portMappings(from ports: [String: [PortBinding]?]) -> [PortMapping] {
        ports.flatMap { containerPort, bindings -> [PortMapping] in
            guard let bindings, !bindings.isEmpty else {
                return [PortMapping(containerPort: containerPort, host: "-", hostPort: "-")]
            }
            return bindings.map {
                PortMapping(
                    containerPort: containerPort,
                    host: $0.hostIP ?? "",
                    hostPort: $0.hostPort ?? "-"
                )
            }
        }
        .sorted { lhs, rhs in
            lhs.containerPort.localizedStandardCompare(rhs.containerPort) == .orderedAscending
        }
    }
}

enum ContainerSortOrder: String, CaseIterable, Identifiable {
    case name
    case project
    case image
    case created

    var id: Self { self }

    var label: String {
        switch self {
        case .name: "Name"
        case .project: "Project"
        case .image: "Image"
        case .created: "Created"
        }
    }

    var systemImage: String {
        switch self {
        case .name: "textformat"
        case .project: "shippingbox"
        case .image: "square.stack.3d.up"
        case .created: "calendar"
        }
    }
}

enum ContainerScope: String, CaseIterable, Identifiable {
    case running
    case all

    var id: Self { self }

    var label: String {
        switch self {
        case .running: "Running"
        case .all: "All"
        }
    }
}

enum CommandError: LocalizedError {
    case commandFailed(command: String, detail: String)

    var errorDescription: String? {
        switch self {
        case let .commandFailed(command, detail):
            return detail.isEmpty ? "\(command) failed" : detail
        }
    }
}

enum ToolRunner {
    static let commonDockerPaths = [
        "/opt/homebrew/bin/docker",
        "/usr/local/bin/docker",
        "/usr/bin/docker"
    ]

    static let commonColimaPaths = [
        "/opt/homebrew/bin/colima",
        "/usr/local/bin/colima"
    ]

    static func executable(named name: String, commonPaths: [String]) -> String {
        for path in commonPaths where FileManager.default.isExecutableFile(atPath: path) {
            return path
        }
        return name
    }

    static func run(_ executable: String, arguments: [String]) async throws -> String {
        try await Task.detached(priority: .userInitiated) {
            let process = Process()
            let resolved = executable.hasPrefix("/") ? executable : "/usr/bin/env"
            process.executableURL = URL(fileURLWithPath: resolved)
            process.arguments = executable.hasPrefix("/") ? arguments : [executable] + arguments
            process.environment = ProcessInfo.processInfo.environment

            let stdout = Pipe()
            let stderr = Pipe()
            process.standardOutput = stdout
            process.standardError = stderr

            try process.run()
            process.waitUntilExit()

            let output = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let error = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            if process.terminationStatus != 0 {
                throw CommandError.commandFailed(
                    command: ([executable] + arguments).joined(separator: " "),
                    detail: error.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            return output
        }.value
    }
}

enum DockerRunner {
    static var docker: String {
        ToolRunner.executable(named: "docker", commonPaths: ToolRunner.commonDockerPaths)
    }

    static func listContainers(scope: ContainerScope) async throws -> [ContainerSummary] {
        let args = scope == .all
            ? ["ps", "--all", "--format", "{{json .}}"]
            : ["ps", "--format", "{{json .}}"]
        let output = try await ToolRunner.run(docker, arguments: args)
        let decoder = JSONDecoder()
        return output
            .split(separator: "\n")
            .compactMap { line in
                try? decoder.decode(DockerPSRecord.self, from: Data(String(line).utf8)).summary
            }
    }

    static func inspect(id: String) async throws -> ContainerDetail {
        let output = try await ToolRunner.run(docker, arguments: ["inspect", id])
        let records = try JSONDecoder().decode([DockerInspectRecord].self, from: Data(output.utf8))
        guard let detail = records.first?.detail else {
            throw CommandError.commandFailed(command: "docker inspect \(id)", detail: "No inspect record returned.")
        }
        return detail
    }

    static func logs(id: String, tailLines: Int) async throws -> String {
        try await ToolRunner.run(docker, arguments: [
            "logs",
            "--tail",
            String(tailLines),
            "--timestamps",
            id
        ])
    }

    static func stop(id: String) async throws -> ContainerDetail {
        _ = try await ToolRunner.run(docker, arguments: ["stop", id])
        let detail = try await inspect(id: id)
        if detail.isRunning {
            throw CommandError.commandFailed(
                command: "docker stop \(id)",
                detail: "Docker reported success, but \(detail.shortID) is still \(detail.stateLabel)."
            )
        }
        return detail
    }

    static func statusText() async -> String {
        do {
            let version = try await ToolRunner.run(docker, arguments: ["info", "--format", "{{.ServerVersion}}"])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let colima = ToolRunner.executable(named: "colima", commonPaths: ToolRunner.commonColimaPaths)
            let colimaStatus = try? await ToolRunner.run(colima, arguments: ["status"])
            if let colimaStatus, colimaStatus.localizedCaseInsensitiveContains("running") {
                return "Colima running | Docker \(version)"
            }
            return "Docker \(version)"
        } catch {
            return "Docker unavailable"
        }
    }
}

@MainActor
final class ContainerStore: ObservableObject {
    @Published var containers: [ContainerSummary] = []
    @Published var selectedContainerID: ContainerSummary.ID?
    @Published var detail: ContainerDetail?
    @Published var logs = ""
    @Published var statusText = "Ready"
    @Published var dockerStatusText = "Checking Docker..."
    @Published var isRefreshing = false
    @Published var isLoadingDetail = false
    @Published var isLoadingLogs = false
    @Published var isStopping = false
    @Published var followLogs = false {
        didSet { updateLogFollower() }
    }
    @Published var tailLines = 200
    @Published var sortOrder: ContainerSortOrder = .project {
        didSet { containers = sorted(containers) }
    }
    @Published var scope: ContainerScope = .running {
        didSet {
            guard !isUpdatingScopeWithoutRefresh else { return }
            refresh()
        }
    }
    @Published var query = ""

    private var refreshTask: Task<Void, Never>?
    private var logFollowTask: Task<Void, Never>?
    private var lastDetailID: ContainerSummary.ID?
    private var isUpdatingScopeWithoutRefresh = false

    var selectedContainer: ContainerSummary? {
        containers.first { $0.id == selectedContainerID }
    }

    var filteredContainers: [ContainerSummary] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return containers }
        return containers.filter { container in
            [
                container.displayName,
                container.image,
                container.projectServiceText,
                container.ports,
                container.status
            ].contains { $0.localizedCaseInsensitiveContains(trimmedQuery) }
        }
    }

    deinit {
        refreshTask?.cancel()
        logFollowTask?.cancel()
    }

    func startAutoRefresh() {
        guard refreshTask == nil else { return }
        refresh()
        refreshDockerStatus()
        refreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(4))
                self?.refresh()
            }
        }
    }

    func refresh() {
        Task {
            await reloadContainers(scope: scope)
        }
    }

    func refreshDockerStatus() {
        Task {
            dockerStatusText = await DockerRunner.statusText()
        }
    }

    func select(_ id: ContainerSummary.ID?) {
        guard selectedContainerID != id else { return }
        selectedContainerID = id
        detail = nil
        logs = ""
        lastDetailID = nil
        followLogs = false
        refreshSelectedDetailIfNeeded(force: true)
    }

    func refreshSelectedDetailIfNeeded(force: Bool = false) {
        guard let selectedContainerID else { return }
        guard force || selectedContainerID != lastDetailID else { return }
        lastDetailID = selectedContainerID
        isLoadingDetail = true
        Task {
            do {
                detail = try await DockerRunner.inspect(id: selectedContainerID)
                await refreshLogs()
            } catch {
                detail = nil
                logs = ""
                statusText = error.localizedDescription
            }
            isLoadingDetail = false
        }
    }

    func refreshLogs() async {
        guard let selectedContainerID else { return }
        isLoadingLogs = true
        do {
            logs = try await DockerRunner.logs(id: selectedContainerID, tailLines: tailLines)
        } catch {
            logs = error.localizedDescription
        }
        isLoadingLogs = false
    }

    func refreshLogsButton() {
        Task { await refreshLogs() }
    }

    func openFirstPort() {
        guard let url = detail?.ports.compactMap(\.url).first else { return }
        NSWorkspace.shared.open(url)
    }

    func copySelectedID() {
        let value = detail?.fullID ?? selectedContainerID ?? ""
        guard !value.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        statusText = "Copied container ID"
    }

    func stopSelected() {
        guard let selectedContainerID else { return }
        stop(selectedContainerID)
    }

    func stop(_ id: ContainerSummary.ID) {
        guard !isStopping else { return }
        let displayName = containers.first { $0.id == id }?.displayName ?? String(id.prefix(12))
        selectedContainerID = id
        detail = nil
        logs = ""
        lastDetailID = nil
        statusText = "Stopping \(displayName)..."
        isStopping = true
        Task {
            defer { isStopping = false }
            do {
                let stoppedDetail = try await DockerRunner.stop(id: id)
                let nextScope = scope == .running ? ContainerScope.all : scope
                setScopeWithoutRefresh(nextScope)
                detail = stoppedDetail
                logs = ""
                lastDetailID = id
                await reloadContainers(
                    scope: nextScope,
                    statusOverride: "Stopped \(displayName); verified \(stoppedDetail.stateLabel)."
                )
                detail = stoppedDetail
                await refreshLogs()
            } catch {
                statusText = error.localizedDescription
            }
        }
    }

    private func reloadContainers(scope requestedScope: ContainerScope, statusOverride: String? = nil) async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let next = sorted(try await DockerRunner.listContainers(scope: requestedScope))
            containers = next
            if let selectedContainerID, !next.contains(where: { $0.id == selectedContainerID }) {
                self.selectedContainerID = nil
                detail = nil
                logs = ""
                lastDetailID = nil
            }
            statusText = statusOverride ?? (next.isEmpty
                ? "No containers found"
                : "\(next.count) container\(next.count == 1 ? "" : "s") shown")
            refreshSelectedDetailIfNeeded()
        } catch {
            containers = []
            selectedContainerID = nil
            detail = nil
            logs = ""
            statusText = error.localizedDescription
        }
    }

    private func setScopeWithoutRefresh(_ nextScope: ContainerScope) {
        guard scope != nextScope else { return }
        isUpdatingScopeWithoutRefresh = true
        scope = nextScope
        isUpdatingScopeWithoutRefresh = false
    }

    private func updateLogFollower() {
        logFollowTask?.cancel()
        logFollowTask = nil
        guard followLogs else { return }
        logFollowTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refreshLogs()
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    private func sorted(_ values: [ContainerSummary]) -> [ContainerSummary] {
        values.sorted { lhs, rhs in
            switch sortOrder {
            case .name:
                compare(lhs.displayName, rhs.displayName)
            case .project:
                compare(lhs.projectServiceText, rhs.projectServiceText) || (
                    lhs.projectServiceText == rhs.projectServiceText &&
                    compare(lhs.displayName, rhs.displayName)
                )
            case .image:
                compare(lhs.image, rhs.image) || (
                    lhs.image == rhs.image &&
                    compare(lhs.displayName, rhs.displayName)
                )
            case .created:
                compare(lhs.runningFor, rhs.runningFor) || (
                    lhs.runningFor == rhs.runningFor &&
                    compare(lhs.displayName, rhs.displayName)
                )
            }
        }
    }

    private func compare(_ lhs: String, _ rhs: String) -> Bool {
        lhs.localizedStandardCompare(rhs) == .orderedAscending
    }
}

struct ContentView: View {
    @EnvironmentObject private var store: ContainerStore

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                ContainerListHeader()

                List(selection: Binding(
                    get: { store.selectedContainerID },
                    set: { store.select($0) }
                )) {
                    ForEach(store.filteredContainers) { container in
                        ContainerRow(container: container)
                            .tag(container.id)
                            .contextMenu {
                                Button("Copy Container ID") { store.copySelectedID() }
                                Button("Open First Port") { store.openFirstPort() }
                                    .disabled(store.detail?.ports.compactMap(\.url).isEmpty ?? true)
                                Button("Stop Container", role: .destructive) { store.stop(container.id) }
                                    .disabled(store.isStopping || !container.isRunning)
                            }
                    }
                }
                .listStyle(.sidebar)
                .overlay {
                    if store.filteredContainers.isEmpty {
                        ContentUnavailableView(
                            store.containers.isEmpty ? "No Containers" : "No Matches",
                            systemImage: "shippingbox",
                            description: Text(store.containers.isEmpty ? "Running Docker containers will appear here." : "Try a different filter.")
                        )
                    }
                }

                Divider()
                StatusBar()
            }
            .navigationSplitViewColumnWidth(min: 340, ideal: 420, max: 520)
        } detail: {
            DetailView()
        }
        .frame(minWidth: 1000, minHeight: 620)
        .toolbar {
            ToolbarItemGroup {
                Picker("Scope", selection: $store.scope) {
                    ForEach(ContainerScope.allCases) { scope in
                        Text(scope.label).tag(scope)
                    }
                }
                .pickerStyle(.segmented)

                SortOrderMenu()

                Button {
                    store.refresh()
                    store.refreshDockerStatus()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }

                Button(role: .destructive) {
                    store.stopSelected()
                } label: {
                    Label("Stop", systemImage: "stop.circle")
                }
                .disabled(store.selectedContainer?.isRunning != true || store.isStopping)
            }
        }
        .searchable(text: $store.query, placement: .sidebar, prompt: "Filter containers")
        .onAppear {
            store.startAutoRefresh()
        }
    }
}

struct ContainerListHeader: View {
    @EnvironmentObject private var store: ContainerStore

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "circle.grid.cross")
                .foregroundStyle(.green)
            Text(store.dockerStatusText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer()
            if store.isRefreshing {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.bar)
    }
}

struct ContainerRow: View {
    let container: ContainerSummary

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            StatusDot(state: container.state, status: container.status, size: 9)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(container.displayName)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                    Text(container.projectServiceText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(container.image)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Label(container.createdAgeText, systemImage: "calendar")
                    Label(container.portSummary, systemImage: "network")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
            }
        }
        .padding(.vertical, 5)
    }
}

struct DetailView: View {
    @EnvironmentObject private var store: ContainerStore

    var body: some View {
        Group {
            if let container = store.selectedContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        DetailHeader(container: container)

                        if store.isLoadingDetail && store.detail == nil {
                            ProgressView("Loading container details...")
                                .frame(maxWidth: .infinity, minHeight: 160)
                        } else if let detail = store.detail {
                            MetadataGrid(detail: detail)
                            ResourceSections(detail: detail)
                            LogsSection()
                        } else {
                            ContentUnavailableView(
                                "Details Unavailable",
                                systemImage: "exclamationmark.triangle",
                                description: Text(store.statusText)
                            )
                            .frame(minHeight: 260)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ContentUnavailableView(
                    "Select a Container",
                    systemImage: "shippingbox",
                    description: Text("Choose a Docker container to inspect metadata and load a bounded log tail.")
                )
            }
        }
    }
}

struct DetailHeader: View {
    @EnvironmentObject private var store: ContainerStore
    let container: ContainerSummary

    var healthLabel: String {
        if let health = store.detail?.health, !health.isEmpty { return health.capitalized }
        return container.status
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                StatusDot(state: container.state, status: container.status, size: 12)
                Text(container.displayName)
                    .font(.title2.weight(.semibold))
                    .lineLimit(1)
                    .truncationMode(.middle)

                StatusPill(text: container.state.capitalized, style: container.isRunning ? .good : .neutral)
                StatusPill(text: healthLabel, style: healthLabel.localizedCaseInsensitiveContains("healthy") ? .good : .neutral)

                Spacer()
            }

            HStack(spacing: 10) {
                Button { store.copySelectedID() } label: {
                    Label("Copy ID", systemImage: "doc.on.doc")
                }

                Button { store.openFirstPort() } label: {
                    Label("Open Port", systemImage: "arrow.up.forward.square")
                }
                .disabled(store.detail?.ports.compactMap(\.url).isEmpty ?? true)

                Button { store.refreshSelectedDetailIfNeeded(force: true) } label: {
                    Label("Refresh Details", systemImage: "arrow.clockwise")
                }

                Button(role: .destructive) { store.stopSelected() } label: {
                    Label("Stop Container", systemImage: "stop.circle")
                }
                .disabled(store.isStopping || !container.isRunning)
            }
            .controlSize(.regular)
        }
    }
}

struct MetadataGrid: View {
    let detail: ContainerDetail

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 34, verticalSpacing: 8) {
            GridRow {
                MetadataColumn(items: [
                    ("Image", detail.image),
                    ("Image ID", String(detail.imageID.prefix(24))),
                    ("Container ID", detail.shortID),
                    ("Command", detail.command),
                    ("Created", formatDockerDate(detail.created))
                ])
                MetadataColumn(items: [
                    ("Compose Project", detail.composeProject ?? "-"),
                    ("Compose Service", detail.composeService ?? "-"),
                    ("Working Directory", detail.workingDirectory ?? "-"),
                    ("Restart Policy", detail.restartPolicy),
                    ("Started", formatDockerDate(detail.startedAt ?? "-"))
                ])
            }
        }
        .padding(.vertical, 4)
    }
}

struct MetadataColumn: View {
    let items: [(String, String)]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 8) {
            ForEach(items, id: \.0) { label, value in
                GridRow {
                    Text(label)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(value.isEmpty ? "-" : value)
                        .font(.callout)
                        .textSelection(.enabled)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}

struct ResourceSections: View {
    let detail: ContainerDetail

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 22, verticalSpacing: 12) {
            GridRow {
                DetailSection(title: "Ports") {
                    if detail.ports.isEmpty {
                        EmptySectionText("No published ports")
                    } else {
                        ForEach(detail.ports) { port in
                            ResourceLine(
                                leading: port.containerPort,
                                trailing: "\(port.displayHost):\(port.hostPort)",
                                symbol: port.url == nil ? "circle" : "circle.fill",
                                color: port.url == nil ? .secondary : .green
                            )
                        }
                    }
                }

                DetailSection(title: "Mounts") {
                    if detail.mounts.isEmpty {
                        EmptySectionText("No mounts")
                    } else {
                        ForEach(detail.mounts.prefix(8)) { mount in
                            ResourceLine(
                                leading: mount.destination,
                                trailing: mount.source,
                                symbol: "externaldrive",
                                color: .blue
                            )
                        }
                    }
                }

                DetailSection(title: "Networks") {
                    if detail.networks.isEmpty {
                        EmptySectionText("No networks")
                    } else {
                        ForEach(detail.networks) { network in
                            ResourceLine(
                                leading: network.name,
                                trailing: network.ipAddress,
                                symbol: "point.3.connected.trianglepath.dotted",
                                color: .purple
                            )
                        }
                    }
                }
            }
        }
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            VStack(alignment: .leading, spacing: 7) {
                content
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct ResourceLine: View {
    let leading: String
    let trailing: String
    let symbol: String
    let color: Color

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.caption2)
                .foregroundStyle(color)
                .frame(width: 14)
            Text(leading)
                .font(.callout.weight(.medium))
                .lineLimit(1)
            Text(trailing)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

struct EmptySectionText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.callout)
            .foregroundStyle(.tertiary)
    }
}

struct LogsSection: View {
    @EnvironmentObject private var store: ContainerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Logs")
                        .font(.headline)
                    Text(store.followLogs ? "Following a bounded tail every 2 seconds." : "Logs are tail-limited and not followed by default.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Toggle("Follow", isOn: $store.followLogs)
                    .toggleStyle(.switch)
                    .frame(width: 92, alignment: .trailing)
                Stepper("Tail \(store.tailLines)", value: $store.tailLines, in: 50...2000, step: 50)
                    .frame(width: 112)
                Button { store.refreshLogsButton() } label: {
                    Label("Refresh Logs", systemImage: "arrow.clockwise")
                }
                .disabled(store.isLoadingLogs)
            }

            ScrollView([.vertical, .horizontal]) {
                Text(colorizedLogText(store.logs.isEmpty ? "No log output returned for the selected tail." : store.logs))
                    .font(.system(size: 12, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .frame(minHeight: 260)
            .background(Color(nsColor: NSColor(calibratedWhite: 0.055, alpha: 1)))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.65), lineWidth: 1)
            }

            HStack {
                Text("Showing last \(store.tailLines) lines.")
                Spacer()
                if store.isLoadingLogs {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func colorizedLogText(_ logs: String) -> AttributedString {
        var result = AttributedString(logs)
        result.foregroundColor = Color(nsColor: NSColor(calibratedWhite: 0.84, alpha: 1))

        let markers: [(String, Color)] = [
            ("ERROR", .red),
            ("ERR", .red),
            ("WARN", .orange),
            ("WARNING", .orange),
            ("INFO", .green),
            ("DEBUG", .blue)
        ]

        for (marker, color) in markers {
            var searchRange = result.startIndex..<result.endIndex
            while let range = result[searchRange].range(of: marker, options: [.caseInsensitive]) {
                result[range].foregroundColor = color
                result[range].font = .system(size: 12, weight: .semibold, design: .monospaced)
                searchRange = range.upperBound..<result.endIndex
            }
        }
        return result
    }
}

struct SortOrderMenu: View {
    @EnvironmentObject private var store: ContainerStore

    var body: some View {
        Menu {
            ForEach(ContainerSortOrder.allCases) { order in
                Button {
                    store.sortOrder = order
                } label: {
                    Label(order.label, systemImage: store.sortOrder == order ? "checkmark" : order.systemImage)
                }
            }
        } label: {
            Label("Sort: \(store.sortOrder.label)", systemImage: store.sortOrder.systemImage)
        }
    }
}

enum PillStyle {
    case good
    case neutral
}

struct StatusPill: View {
    let text: String
    let style: PillStyle

    var body: some View {
        Text(text.isEmpty ? "-" : text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var background: Color {
        switch style {
        case .good: Color.green.opacity(0.18)
        case .neutral: Color.secondary.opacity(0.16)
        }
    }

    private var foreground: Color {
        switch style {
        case .good: .green
        case .neutral: .secondary
        }
    }
}

struct StatusDot: View {
    let state: String
    let status: String
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .overlay {
                Circle()
                    .stroke(.white.opacity(0.35), lineWidth: 1)
            }
            .shadow(color: color.opacity(0.45), radius: size * 0.45)
            .accessibilityLabel(accessibilityText)
    }

    private var color: Color {
        if status.localizedCaseInsensitiveContains("unhealthy") {
            return .red
        }
        if status.localizedCaseInsensitiveContains("healthy") {
            return .green
        }
        if state.localizedCaseInsensitiveContains("running") {
            return .green
        }
        if state.localizedCaseInsensitiveContains("exited") {
            return .secondary
        }
        return .orange
    }

    private var accessibilityText: String {
        status.isEmpty ? state : status
    }
}

struct StatusBar: View {
    @EnvironmentObject private var store: ContainerStore

    var body: some View {
        HStack(spacing: 8) {
            Text(store.statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer()
            Text(store.scope == .running ? "Running only" : "All containers")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct MenuBarContent: View {
    @EnvironmentObject private var store: ContainerStore

    var body: some View {
        Button("Refresh") {
            store.refresh()
            store.refreshDockerStatus()
        }

        Menu("Scope") {
            ForEach(ContainerScope.allCases) { scope in
                Button(scope.label) { store.scope = scope }
            }
        }

        Menu("Sort By") {
            ForEach(ContainerSortOrder.allCases) { order in
                Button(order.label) { store.sortOrder = order }
            }
        }

        Divider()

        if store.containers.isEmpty {
            Text("No containers")
        } else {
            ForEach(store.containers.prefix(20)) { container in
                Button(container.displayName) {
                    store.select(container.id)
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }

        Divider()

        Button("Quit") {
            NSApp.terminate(nil)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

@main
struct ContainerReviewApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = ContainerStore()

    var body: some Scene {
        WindowGroup("Container Review") {
            ContentView()
                .environmentObject(store)
        }

        MenuBarExtra("Container Review", systemImage: "shippingbox") {
            MenuBarContent()
                .environmentObject(store)
                .onAppear {
                    store.startAutoRefresh()
                }
        }

        .commands {
            CommandGroup(after: .newItem) {
                Button("Refresh Containers") {
                    store.refresh()
                    store.refreshDockerStatus()
                }
                .keyboardShortcut("r", modifiers: [.command])

                Button("Refresh Logs") {
                    store.refreshLogsButton()
                }
                .keyboardShortcut("l", modifiers: [.command])
                .disabled(store.selectedContainer == nil)
            }
        }
    }
}

private func formatDockerDate(_ value: String) -> String {
    guard !value.isEmpty, value != "-" else { return "-" }
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter.date(from: value) {
        return date.formatted(date: .abbreviated, time: .shortened)
    }
    formatter.formatOptions = [.withInternetDateTime]
    if let date = formatter.date(from: value) {
        return date.formatted(date: .abbreviated, time: .shortened)
    }
    return value
}
