import XCTest
import Node
@testable import Settings
@testable import Vapor

class ConfigTests: XCTestCase {
    static let allTests = [
        ("testLoad", testLoad),
        ("testExample", testExample),
        ("testEmpty", testEmpty),
        ("testConversions", testConversions),
    ]
    
    func testLoad() throws {
        let config = try Config(
            prioritized: [
                .directory(root: configDir.finished(with: "/") + "inner"),
                .directory(root: configDir)
            ]
        )
        let expectation: Node = [
            "test": [
                "name": "inner/test"
            ],
            "file": ["hello": .bytes("Hello!\n".makeBytes())]
        ]
        XCTAssertEqual(config, Config(expectation))
    }

    func testExample() throws {
        let config = try Config(
            prioritized: [
                .memory(name: "app", config: ["port": 8080]),
                .commandLine
            ]
        )

        let expectation: Node = [
            "app": [
                "port": 8080
            ]
        ]
        XCTAssertEqual(config, Config(expectation))
    }

    func testEmpty() throws {
        let config = try Config(
            prioritized: [
                .directory(root: "i/dont/exist")
            ]
        )
        XCTAssertEqual(config, Config([:]))
    }

    func testConversions() throws {
        let node: Node = [
            "name": "World"
        ]

        let config: Config = node.converted()
        let back: Node = config.converted()
        XCTAssertEqual(node, back)
    }

    func testExplosion() throws {
        var config = Config([:])
        try config.set("bool", true)
        try config.set("array", [1,2,3,4,5])

        var sub = Config([:])
        try sub.set("bool", false)
        try sub.set("array", ["a", "b", "c"])

        try config.set("sub", sub)

        let exploded = try config.explode()
        print(exploded)
        print("")
    }

    func testConfigDiffing() throws {
        var original = Config([:])
        try original.set("update", true)
        try original.set("lost", 132)
        try original.set("do.a.path", ["hello": "world"])

        var new = Config([:])
        try new.set("update", false)
        try new.set("addition", "hello")
        try new.set("do.a.path", ["hello": "mars"])
        
        let updates = try original.changes(comparedTo: new)
        print(updates)
        print("")
    }
}
