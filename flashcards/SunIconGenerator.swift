import SwiftUI
import UIKit

struct SunIconGenerator {
    static func generateSunIcon(size: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // Create gradient background
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0).cgColor, // Bright orange
                UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0).cgColor  // Darker orange
            ]
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0])!
            
            // Draw gradient background
            cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: [])
            
            // Sun parameters
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let sunRadius = min(size.width, size.height) * 0.25
            let rayLength = sunRadius * 0.8
            let rayWidth = sunRadius * 0.08
            
            // Draw sun rays
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.setStrokeColor(UIColor.white.cgColor)
            cgContext.setLineWidth(rayWidth)
            
            let numberOfRays = 16
            for i in 0..<numberOfRays {
                let angle = (Double(i) * 2 * Double.pi) / Double(numberOfRays)
                let startX = center.x + cos(angle) * sunRadius
                let startY = center.y + sin(angle) * sunRadius
                let endX = center.x + cos(angle) * (sunRadius + rayLength)
                let endY = center.y + sin(angle) * (sunRadius + rayLength)
                
                cgContext.move(to: CGPoint(x: startX, y: startY))
                cgContext.addLine(to: CGPoint(x: endX, y: endY))
                cgContext.strokePath()
            }
            
            // Draw sun body (white circle)
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.setStrokeColor(UIColor.white.cgColor)
            cgContext.setLineWidth(4)
            
            let sunRect = CGRect(
                x: center.x - sunRadius,
                y: center.y - sunRadius,
                width: sunRadius * 2,
                height: sunRadius * 2
            )
            cgContext.fillEllipse(in: sunRect)
            cgContext.strokeEllipse(in: sunRect)
            
            // Draw smiley face
            let faceRadius = sunRadius * 0.6
            
            // Eyes
            let eyeRadius = faceRadius * 0.15
            let eyeY = center.y - faceRadius * 0.2
            let eyeSpacing = faceRadius * 0.6
            
            cgContext.setFillColor(UIColor.white.cgColor)
            
            // Left eye
            let leftEyeRect = CGRect(
                x: center.x - eyeSpacing - eyeRadius,
                y: eyeY - eyeRadius,
                width: eyeRadius * 2,
                height: eyeRadius * 2
            )
            cgContext.fillEllipse(in: leftEyeRect)
            
            // Right eye
            let rightEyeRect = CGRect(
                x: center.x + eyeSpacing - eyeRadius,
                y: eyeY - eyeRadius,
                width: eyeRadius * 2,
                height: eyeRadius * 2
            )
            cgContext.fillEllipse(in: rightEyeRect)
            
            // Smile
            cgContext.setStrokeColor(UIColor.white.cgColor)
            cgContext.setLineWidth(rayWidth * 1.5)
            cgContext.setLineCap(.round)
            
            let smileRadius = faceRadius * 0.7
            
            cgContext.addArc(center: center, radius: smileRadius, startAngle: .pi * 0.2, endAngle: .pi * 0.8, clockwise: false)
            cgContext.strokePath()
        }
    }
}

// SwiftUI view for preview
struct SunIconPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: SunIconGenerator.generateSunIcon(size: CGSize(width: 200, height: 200)))
                .resizable()
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 40))
            
            Text("Sun Icon Preview")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("1024x1024 version will be generated for the app icon")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    SunIconPreview()
}
