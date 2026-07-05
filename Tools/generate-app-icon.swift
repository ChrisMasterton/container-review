import AppKit

private let canvasSize: CGFloat = 1024

private struct RGBA {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    var color: NSColor {
        NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
}

private func roundedRect(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

private func polygon(_ points: [NSPoint]) -> NSBezierPath {
    let path = NSBezierPath()
    guard let first = points.first else { return path }
    path.move(to: first)
    for point in points.dropFirst() {
        path.line(to: point)
    }
    path.close()
    return path
}

private func strokeLine(_ points: [NSPoint], color: NSColor, width: CGFloat) {
    let path = NSBezierPath()
    guard let first = points.first else { return }
    path.move(to: first)
    for point in points.dropFirst() {
        path.line(to: point)
    }
    path.lineWidth = width
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    color.setStroke()
    path.stroke()
}

private func withShadow(color: NSColor, offset: NSSize, blur: CGFloat, draw: () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = color
    shadow.shadowOffset = offset
    shadow.shadowBlurRadius = blur
    shadow.set()
    draw()
    NSGraphicsContext.restoreGraphicsState()
}

private func drawIcon(in rect: NSRect) {
    NSGraphicsContext.saveGraphicsState()
    let transform = NSAffineTransform()
    transform.translateX(by: rect.minX, yBy: rect.minY)
    transform.scale(by: rect.width / canvasSize)
    transform.concat()

    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: canvasSize, height: canvasSize).fill()

    let shell = roundedRect(NSRect(x: 64, y: 64, width: 896, height: 896), radius: 210)
    withShadow(
        color: NSColor.black.withAlphaComponent(0.38),
        offset: NSSize(width: 0, height: -34),
        blur: 54
    ) {
        let background = NSGradient(colors: [
            RGBA(red: 0.035, green: 0.075, blue: 0.105, alpha: 1).color,
            RGBA(red: 0.035, green: 0.215, blue: 0.255, alpha: 1).color,
            RGBA(red: 0.060, green: 0.380, blue: 0.390, alpha: 1).color
        ])
        background?.draw(in: shell, angle: -38)
    }

    NSGraphicsContext.saveGraphicsState()
    shell.addClip()

    let glintPath = NSBezierPath(ovalIn: NSRect(x: -120, y: 688, width: 980, height: 360))
    let glint = NSGradient(colors: [
        NSColor.white.withAlphaComponent(0.18),
        NSColor.white.withAlphaComponent(0.00)
    ])
    glint?.draw(in: glintPath, angle: -74)

    for index in 0..<6 {
        let x = CGFloat(index) * 176 + 36
        strokeLine(
            [NSPoint(x: x, y: 128), NSPoint(x: x + 430, y: 958)],
            color: NSColor.white.withAlphaComponent(0.045),
            width: 14
        )
    }
    NSGraphicsContext.restoreGraphicsState()

    let topFace = polygon([
        NSPoint(x: 294, y: 698),
        NSPoint(x: 696, y: 698),
        NSPoint(x: 796, y: 602),
        NSPoint(x: 394, y: 602)
    ])
    NSGradient(colors: [
        RGBA(red: 0.220, green: 0.725, blue: 0.710, alpha: 1).color,
        RGBA(red: 0.090, green: 0.405, blue: 0.480, alpha: 1).color
    ])?.draw(in: topFace, angle: -16)

    let sideFace = polygon([
        NSPoint(x: 696, y: 302),
        NSPoint(x: 796, y: 398),
        NSPoint(x: 796, y: 602),
        NSPoint(x: 696, y: 698)
    ])
    NSGradient(colors: [
        RGBA(red: 0.055, green: 0.205, blue: 0.265, alpha: 1).color,
        RGBA(red: 0.025, green: 0.105, blue: 0.160, alpha: 1).color
    ])?.draw(in: sideFace, angle: 0)

    let frontFace = roundedRect(NSRect(x: 228, y: 302, width: 468, height: 396), radius: 52)
    withShadow(
        color: NSColor.black.withAlphaComponent(0.30),
        offset: NSSize(width: 0, height: -20),
        blur: 32
    ) {
        NSGradient(colors: [
            RGBA(red: 0.105, green: 0.255, blue: 0.315, alpha: 1).color,
            RGBA(red: 0.035, green: 0.115, blue: 0.170, alpha: 1).color
        ])?.draw(in: frontFace, angle: -90)
    }

    for x in stride(from: CGFloat(304), through: CGFloat(620), by: CGFloat(79)) {
        strokeLine(
            [NSPoint(x: x, y: 358), NSPoint(x: x, y: 642)],
            color: NSColor.white.withAlphaComponent(0.135),
            width: 22
        )
    }

    for y in stride(from: CGFloat(410), through: CGFloat(586), by: CGFloat(88)) {
        strokeLine(
            [NSPoint(x: 276, y: y), NSPoint(x: 648, y: y)],
            color: NSColor.black.withAlphaComponent(0.18),
            width: 12
        )
        strokeLine(
            [NSPoint(x: 276, y: y + 11), NSPoint(x: 648, y: y + 11)],
            color: NSColor.white.withAlphaComponent(0.10),
            width: 5
        )
    }

    let lidLine = NSBezierPath()
    lidLine.move(to: NSPoint(x: 394, y: 602))
    lidLine.line(to: NSPoint(x: 796, y: 602))
    lidLine.lineWidth = 11
    lidLine.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.18).setStroke()
    lidLine.stroke()

    for point in [
        NSPoint(x: 304, y: 630),
        NSPoint(x: 372, y: 630),
        NSPoint(x: 440, y: 630)
    ] {
        let dot = NSBezierPath(ovalIn: NSRect(x: point.x - 15, y: point.y - 15, width: 30, height: 30))
        RGBA(red: 0.370, green: 0.970, blue: 0.505, alpha: 1).color.setFill()
        dot.fill()
    }

    let lensRect = NSRect(x: 556, y: 226, width: 244, height: 244)
    let lens = NSBezierPath(ovalIn: lensRect)
    withShadow(
        color: NSColor.black.withAlphaComponent(0.34),
        offset: NSSize(width: 0, height: -12),
        blur: 26
    ) {
        NSColor(calibratedWhite: 0.04, alpha: 0.72).setFill()
        lens.fill()
    }

    strokeLine(
        [NSPoint(x: 750, y: 274), NSPoint(x: 864, y: 160)],
        color: RGBA(red: 1.000, green: 0.690, blue: 0.200, alpha: 1).color,
        width: 58
    )
    strokeLine(
        [NSPoint(x: 750, y: 274), NSPoint(x: 864, y: 160)],
        color: NSColor.white.withAlphaComponent(0.25),
        width: 22
    )

    lens.lineWidth = 42
    RGBA(red: 0.780, green: 0.955, blue: 1.000, alpha: 1).color.setStroke()
    lens.stroke()

    let lensHighlight = NSBezierPath()
    lensHighlight.appendArc(
        withCenter: NSPoint(x: 678, y: 348),
        radius: 78,
        startAngle: 118,
        endAngle: 166,
        clockwise: false
    )
    lensHighlight.lineWidth = 12
    lensHighlight.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.54).setStroke()
    lensHighlight.stroke()

    strokeLine(
        [
            NSPoint(x: 622, y: 350),
            NSPoint(x: 666, y: 306),
            NSPoint(x: 740, y: 394)
        ],
        color: RGBA(red: 0.340, green: 1.000, blue: 0.510, alpha: 1).color,
        width: 38
    )

    NSGraphicsContext.restoreGraphicsState()
}

private func writePNG(size: Int, to url: URL) throws {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "ContainerReviewIcon", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Unable to create bitmap representation."
        ])
    }

    rep.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    drawIcon(in: NSRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size)))
    NSGraphicsContext.restoreGraphicsState()

    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "ContainerReviewIcon", code: 2, userInfo: [
            NSLocalizedDescriptionKey: "Unable to encode PNG."
        ])
    }
    try data.write(to: url, options: .atomic)
}

let outputDirectory = CommandLine.arguments.dropFirst().first.map {
    URL(fileURLWithPath: $0, isDirectory: true)
} ?? URL(fileURLWithPath: "AppIcon.iconset", isDirectory: true)

try FileManager.default.createDirectory(
    at: outputDirectory,
    withIntermediateDirectories: true,
    attributes: nil
)

let outputs: [(filename: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for output in outputs {
    try writePNG(size: output.pixels, to: outputDirectory.appendingPathComponent(output.filename))
}
