import PackagePlugin
import struct Foundation.URL

@main
struct SwiftFormatBuildToolPlugin: BuildToolPlugin {
    /// Entry point for creating build commands for targets in Swift packages.
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        return []
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftFormatBuildToolPlugin: XcodeBuildToolPlugin {
    // Entry point for creating build commands for targets in Xcode projects.
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let directoryURL = context.xcodeProject.directoryURL;
        let configFile = directoryURL.appending(path: ".swift-format")
        let sourceFiles = directoryURL.appending(path: "SwiftUISwiftData")
        let testFiles = directoryURL.appending(path: "SwiftUISwiftDataTests")
        return [
            .buildCommand(
                displayName: "Run swift format(xcode)",
                executable: try context.tool(named: "swift").url,
                arguments: [
                    "format",
                    "lint",
                    "--configuration",
                    configFile.path(),
                    "-r",
                    sourceFiles.path(),
                    testFiles.path(),
                ],
                inputFiles: [],
                outputFiles: []
            )
        ]    }
}

#endif

extension SwiftFormatBuildToolPlugin {
    /// Shared function that returns a configured build command if the input files is one that should be processed.
    func createBuildCommand(for inputPath: URL, in outputDirectoryPath: URL, with generatorToolPath: URL) -> Command? {
        // Skip any file that doesn't have the extension we're looking for (replace this with the actual one).
        guard inputPath.pathExtension == "my-input-suffix" else { return .none }

        // Return a command that will run during the build to generate the output file.
        let inputName = inputPath.lastPathComponent
        let outputName = inputPath.deletingPathExtension().lastPathComponent + ".swift"
        let outputPath = outputDirectoryPath.appendingPathComponent(outputName)
        return .buildCommand(
            displayName: "Generating \(outputName) from \(inputName)",
            executable: generatorToolPath,
            arguments: ["\(inputPath)", "-o", "\(outputPath)"],
            inputFiles: [inputPath],
            outputFiles: [outputPath]
        )
    }
}
