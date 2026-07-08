import Testing
@testable import ContainerReviewCore

@Test func lsofParserReadsIpv4AndIpv6Listeners() {
    let output = """
    COMMAND     PID  USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
    node      86879 chris   13u  IPv6 0xfe6cefdf75dc1650      0t0  TCP *:3000 (LISTEN)
    Discord   21562 chris   39u  IPv4 0x6d581897bb3ad8ba      0t0  TCP 127.0.0.1:6463 (LISTEN)
    node      32739 chris   16u  IPv6 0x15575e138f1cc324      0t0  TCP [::1]:5173 (LISTEN)
    """

    let listeners = LsofListenParser.parse(output)

    #expect(listeners.count == 3)
    #expect(listeners[0].command == "node")
    #expect(listeners[0].pid == 86879)
    #expect(listeners[0].address == "*")
    #expect(listeners[0].port == 3000)
    #expect(listeners[2].address == "::1")
    #expect(listeners[2].port == 5173)
}

@Test func dockerPublishedPortParserIgnoresUnpublishedContainerPorts() {
    let ports = DockerPublishedPortParser.parse(
        "0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp, 80/tcp"
    )

    #expect(ports == [
        DockerPublishedPort(hostAddress: "0.0.0.0", hostPort: 3000),
        DockerPublishedPort(hostAddress: "::", hostPort: 3000)
    ])
}
