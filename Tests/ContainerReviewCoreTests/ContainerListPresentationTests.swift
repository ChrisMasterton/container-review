import Testing
@testable import ContainerReviewCore

@Test func runningScopeEmptyStatusMentionsHiddenContainers() {
    #expect(ContainerListPresentation.statusText(
        visibleCount: 0,
        isRunningScope: true,
        hiddenNonRunningCount: 346
    ) == "No running containers; 346 containers hidden by Running scope")
}

@Test func runningScopeEmptyDescriptionExplainsNonRunningContainers() {
    #expect(ContainerListPresentation.emptyDescription(
        hasVisibleContainers: false,
        isRunningScope: true,
        hiddenNonRunningCount: 1
    ) == "1 container is not running. Show all containers to inspect them.")
}

@Test func runningScopeEmptyDescriptionPluralizesHiddenContainers() {
    #expect(ContainerListPresentation.emptyDescription(
        hasVisibleContainers: false,
        isRunningScope: true,
        hiddenNonRunningCount: 346
    ) == "346 containers are not running. Show all containers to inspect them.")
}

@Test func allScopeEmptyKeepsGenericNoContainersMessage() {
    #expect(ContainerListPresentation.statusText(
        visibleCount: 0,
        isRunningScope: false,
        hiddenNonRunningCount: nil
    ) == "No containers found")
}

@Test func queryEmptyStateStillReportsNoMatches() {
    #expect(ContainerListPresentation.emptyTitle(
        hasVisibleContainers: true,
        isRunningScope: true,
        hiddenNonRunningCount: 10
    ) == "No Matches")
}
