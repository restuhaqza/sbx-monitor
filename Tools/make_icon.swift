// Draws the Sbx Monitor app icon at 1024x1024 and writes a PNG.
// Usage: swift Tools/make_icon.swift [out.png]
import AppKit
import CoreGraphics
import ImageIO
import Foundation

let S: CGFloat = 1024
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon-1024.png"

let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: Int(S), height: Int(S),
                          bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    fatalError("Could not create bitmap context")
}
NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: cs, components: [r, g, b, a])!
}

func fillPolygon(_ points: [CGPoint], _ color: CGColor) {
    let path = CGMutablePath()
    path.move(to: points[0])
    for p in points.dropFirst() { path.addLine(to: p) }
    path.closeSubpath()
    ctx.addPath(path)
    ctx.setFillColor(color)
    ctx.fillPath()
}

// MARK: - Squircle background (macOS icon grid: 824pt shape, ~185pt radius)

let inset: CGFloat = 100
let rect = CGRect(x: inset, y: inset, width: S - inset * 2, height: S - inset * 2)
let shape = CGPath(roundedRect: rect, cornerWidth: 185, cornerHeight: 185, transform: nil)

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 42, color: rgb(0, 0, 0, 0.38))
ctx.addPath(shape)
ctx.setFillColor(rgb(1, 1, 1))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(shape)
ctx.clip()

// Base gradient
let gradient = CGGradient(colorsSpace: cs,
                          colors: [rgb(0.30, 0.62, 1.00), rgb(0.05, 0.26, 0.82)] as CFArray,
                          locations: [0, 1])!
ctx.drawLinearGradient(gradient,
                       start: CGPoint(x: rect.minX, y: rect.maxY),
                       end: CGPoint(x: rect.maxX, y: rect.minY),
                       options: [])

// Soft highlight glow
let glow = CGGradient(colorsSpace: cs,
                      colors: [rgb(1, 1, 1, 0.22), rgb(1, 1, 1, 0.0)] as CFArray,
                      locations: [0, 1])!
ctx.drawRadialGradient(glow,
                       startCenter: CGPoint(x: 340, y: 780), startRadius: 0,
                       endCenter: CGPoint(x: 340, y: 780), endRadius: 640,
                       options: [])
ctx.restoreGState()

// MARK: - Isometric cube (the "sandbox")

let cx: CGFloat = 500, cy: CGFloat = 450
let tw: CGFloat = 205, th: CGFloat = 118, depth: CGFloat = 195

let topN = CGPoint(x: cx, y: cy + th)
let topE = CGPoint(x: cx + tw, y: cy)
let topS = CGPoint(x: cx, y: cy - th)
let topW = CGPoint(x: cx - tw, y: cy)
let botS = CGPoint(x: cx, y: cy - th - depth)
let botE = CGPoint(x: cx + tw, y: cy - depth)
let botW = CGPoint(x: cx - tw, y: cy - depth)

fillPolygon([topW, topS, botS, botW], rgb(1, 1, 1, 0.72)) // left face
fillPolygon([topS, topE, botE, botS], rgb(1, 1, 1, 0.52)) // right face
fillPolygon([topN, topE, topS, topW], rgb(1, 1, 1, 0.97)) // top face

// Crisp edges
func stroke(_ points: [CGPoint], _ alpha: CGFloat, _ width: CGFloat) {
    let path = CGMutablePath()
    path.move(to: points[0])
    for p in points.dropFirst() { path.addLine(to: p) }
    path.closeSubpath()
    ctx.addPath(path)
    ctx.setStrokeColor(rgb(1, 1, 1, alpha))
    ctx.setLineWidth(width)
    ctx.setLineJoin(.round)
    ctx.strokePath()
}
stroke([topN, topE, topS, topW], 0.9, 7)
stroke([topW, topS, botS, botW], 0.65, 7)
stroke([topS, topE, botE, botS], 0.5, 7)

// MARK: - Cloud (the "cloud" in cloud sandbox)

let cloud = NSBezierPath()
cloud.windingRule = .nonZero
cloud.appendRoundedRect(CGRect(x: 336, y: 632, width: 372, height: 130), xRadius: 65, yRadius: 65)

func cloudCircle(_ center: CGPoint, _ r: CGFloat) {
    cloud.appendOval(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
}
cloudCircle(CGPoint(x: 408, y: 762), 82)
cloudCircle(CGPoint(x: 516, y: 806), 106)
cloudCircle(CGPoint(x: 628, y: 756), 78)

NSColor.white.withAlphaComponent(0.96).setFill()
cloud.fill()

// MARK: - Status indicator dot (the "monitoring" signal)

let dotCenter = CGPoint(x: 792, y: 258)
let dotRadius: CGFloat = 96

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 22, color: rgb(0, 0, 0, 0.30))
ctx.setFillColor(rgb(1, 1, 1))
ctx.fillEllipse(in: CGRect(x: dotCenter.x - dotRadius, y: dotCenter.y - dotRadius,
                           width: dotRadius * 2, height: dotRadius * 2))
ctx.restoreGState()

let dotRect = CGRect(x: dotCenter.x - dotRadius + 14, y: dotCenter.y - dotRadius + 14,
                     width: (dotRadius - 14) * 2, height: (dotRadius - 14) * 2)
let dotGradient = CGGradient(colorsSpace: cs,
                             colors: [rgb(0.36, 0.90, 0.44), rgb(0.10, 0.68, 0.28)] as CFArray,
                             locations: [0, 1])!
ctx.saveGState()
ctx.addEllipse(in: dotRect)
ctx.clip()
ctx.drawLinearGradient(dotGradient,
                       start: CGPoint(x: dotRect.minX, y: dotRect.maxY),
                       end: CGPoint(x: dotRect.maxX, y: dotRect.minY),
                       options: [])
ctx.restoreGState()

// MARK: - Write PNG

guard let image = ctx.makeImage() else { fatalError("Could not make image") }
let url = URL(fileURLWithPath: outPath)
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
    fatalError("Could not create image destination")
}
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("Could not write PNG") }
print("Wrote \(outPath)")
