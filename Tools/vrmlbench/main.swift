import Foundation

// Runs VRMLParser on each file given on the command line and prints part,
// triangle and vertex counts plus parse time. Exits non-zero if any file fails.
// Build and run on the fixtures with `make vrml-bench` (files in fixtures/invalid
// are expected to fail).

let paths = CommandLine.arguments.dropFirst()
if paths.isEmpty {
    print("usage: vrmlbench file.wrl [file.wrl …]")
    exit(2)
}

func pad(_ s: String, _ width: Int, left: Bool = false) -> String {
    let fill = String(repeating: " ", count: max(0, width - s.count))
    return left ? s + fill : fill + s
}

var failures = 0
print(pad("file", 44, left: true) + pad("bytes", 11) + pad("parts", 8) + pad("triangles", 11) + pad("vertices", 11) + pad("ms", 9))
for path in paths {
    let url = URL(fileURLWithPath: path)
    let name = pad(url.lastPathComponent, 44, left: true)
    let size = ((try? FileManager.default.attributesOfItem(atPath: path)[.size]) as? Int) ?? 0
    let start = CFAbsoluteTimeGetCurrent()
    do {
        let scene = try VRMLParser.parse(url: url)
        let ms = (CFAbsoluteTimeGetCurrent() - start) * 1000
        print(name + pad("\(size)", 11) + pad("\(scene.parts.count)", 8) + pad("\(scene.triangleCount)", 11)
              + pad("\(scene.vertexCount)", 11) + pad(String(format: "%.1f", ms), 9)
              + (scene.skippedInlines > 0 ? "  (\(scene.skippedInlines) Inline skipped)" : ""))
    } catch {
        let ms = (CFAbsoluteTimeGetCurrent() - start) * 1000
        failures += 1
        print(name + pad("\(size)", 11) + String(format: "  ERROR after %.1f ms: ", ms) + error.localizedDescription)
    }
}
exit(failures == 0 ? 0 : 1)
