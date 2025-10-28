import SwiftUI


struct PartialRoundedBorder: Shape {
    let cornerRadius: CGFloat
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Top edge with rounded corners
        let topLeft = CGPoint(x: rect.minX, y: rect.minY + cornerRadius)
        _ = CGPoint(x: rect.maxX, y: rect.minY + cornerRadius)

        path.move(to: topLeft)
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Top right vertical line
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + lineWidth))

        // Top left vertical line
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + lineWidth))

        return path
    }
}

struct RoundedCorners: Shape {
    var lineWidth: CGFloat = 0
    var tl: CGFloat = 0
    var tr: CGFloat = 0
    var bl: CGFloat = 0
    var br: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        let tr = min(min(self.tr, h / 2), w / 2)
        let tl = min(min(self.tl, h / 2), w / 2)
        let bl = min(min(self.bl, h / 2), w / 2)
        let br = min(min(self.br, h / 2), w / 2)

        path.move(to: CGPoint(x: w / 2, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(
            center: CGPoint(x: w - tr, y: tr), radius: tr,
            startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(
            center: CGPoint(x: w - br, y: h - br), radius: br,
            startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(
            center: CGPoint(x: bl, y: h - bl), radius: bl,
            startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(
            center: CGPoint(x: tl, y: tl), radius: tl,
            startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()

        return path
    }
}
