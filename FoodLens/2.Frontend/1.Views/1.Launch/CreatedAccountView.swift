//
//  CreatedAccountView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI
import UIKit   // for CAEmitterLayer

struct CreatedAccountView: View {
    // Callback when done
    var onFinished: () -> Void

    // Animation states
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0.0
    @State private var showConfetti: Bool = false

    private let fadeInDuration: TimeInterval = 0.5
    private let delayDuration: TimeInterval = 1.35
    private let fadeOutDuration: TimeInterval = 0.5

    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()

            VStack {
                TitleComponent(title: "All Set!")
                Spacer()

                VStack(spacing: 30) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundStyle(.fgreen)
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)

                    Text("Your account is ready")
                        .foregroundStyle(.fblack)
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .opacity(iconOpacity)
                }

                Spacer()
                Spacer()
            }
            .padding()

            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            animate()
        }
    }

    private func animate() {
        // 1. Start confetti + fade/scale in
        showConfetti = true

        withAnimation(.spring(response: fadeInDuration, dampingFraction: 0.7)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }

        // 2. HOLD FOR A MOMENT
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeInDuration + delayDuration) {

            // 3. FADE + SCALE OUT
            withAnimation(.easeInOut(duration: fadeOutDuration)) {
                iconScale = 0.8
                iconOpacity = 0.0
            }

            // Stop showing confetti a bit before/with navigation (optional)
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDuration * 0.5) {
                showConfetti = false
            }

            // 4. After fade-out finishes -> navigate home
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDuration) {
                onFinished()
            }
        }
    }
}

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 2)

        // FoodLens colors as UIColor
        let uiColors: [UIColor] = [
            UIColor(Color.fblack),
            UIColor(Color.fblue),
            UIColor(Color.fbrown),
            UIColor(Color.fdarkblue),
            UIColor(Color.fdarkgreen),
            UIColor(Color.fgray),
            UIColor(Color.fgreen),
            UIColor(Color.forange),
            UIColor(Color.fred),
            UIColor(Color.fsplash),
            UIColor(Color.fwhite),
            UIColor(Color.fyellow)
        ]

        var cells: [CAEmitterCell] = []

        for color in uiColors {
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 5.0
            cell.velocity = 180
            cell.velocityRange = 120
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 3
            cell.spin = 2.5
            cell.spinRange = 1.2

            // Big confetti pieces
            cell.scale = 0.2
            cell.scaleRange = 0.1

            // use a pre-tinted rectangle image
            cell.contents = UIImage.confettiRect(color: color).cgImage

            cells.append(cell)
        }

        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)

        // Stop creating new pieces after a bit; existing ones keep falling
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            emitter.birthRate = 0
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Helper to generate a colored rectangle image
extension UIImage {
    static func confettiRect(color: UIColor,
                             size: CGSize = CGSize(width: 10, height: 18)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
