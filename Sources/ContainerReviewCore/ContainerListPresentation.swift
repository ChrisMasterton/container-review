public enum ContainerListPresentation {
    public static func statusText(
        visibleCount: Int,
        isRunningScope: Bool,
        hiddenNonRunningCount: Int?
    ) -> String {
        guard visibleCount == 0 else {
            return "\(visibleCount) container\(visibleCount == 1 ? "" : "s") shown"
        }

        if isRunningScope, let hiddenNonRunningCount, hiddenNonRunningCount > 0 {
            return "No running containers; \(containerCountText(hiddenNonRunningCount)) hidden by Running scope"
        }

        return isRunningScope ? "No running containers" : "No containers found"
    }

    public static func emptyTitle(
        hasVisibleContainers: Bool,
        isRunningScope: Bool,
        hiddenNonRunningCount: Int?
    ) -> String {
        guard !hasVisibleContainers else { return "No Matches" }
        if isRunningScope { return "No Running Containers" }
        return "No Containers"
    }

    public static func emptyDescription(
        hasVisibleContainers: Bool,
        isRunningScope: Bool,
        hiddenNonRunningCount: Int?
    ) -> String {
        guard !hasVisibleContainers else { return "Try a different filter." }

        if isRunningScope, let hiddenNonRunningCount, hiddenNonRunningCount > 0 {
            return "\(containerRunningStateText(hiddenNonRunningCount)). Show all containers to inspect them."
        }

        return isRunningScope
            ? "Docker did not report any running containers."
            : "Docker did not report any containers."
    }

    public static func menuEmptyText(
        isRunningScope: Bool,
        hiddenNonRunningCount: Int?
    ) -> String {
        if isRunningScope, let hiddenNonRunningCount, hiddenNonRunningCount > 0 {
            return "No running containers (\(hiddenNonRunningCount) non-running)"
        }

        return isRunningScope ? "No running containers" : "No containers"
    }

    private static func containerCountText(_ count: Int) -> String {
        "\(count) container\(count == 1 ? "" : "s")"
    }

    private static func containerRunningStateText(_ count: Int) -> String {
        "\(containerCountText(count)) \(count == 1 ? "is" : "are") not running"
    }
}
