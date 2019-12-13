//
//  GenerateProgressView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 11/26/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI

struct GenerateProgressView: View {
    
    @State private var progress: CGFloat = 0.0
    @State private var isLoading: Bool = true
    @State private var isGenerationComplete: Bool = false
    @EnvironmentObject var session: Session
    @EnvironmentObject var flow: GenerateFlow

    private var image: UIImage {
        return session.image
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text("Generating icons...")
                .font(Font.system(size: 16.0, weight: .semibold))
                .multilineTextAlignment(.center)
            
            ProgressView(progress: progress, backgroundColor: Color.gray.opacity(0.5))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 10.0)
                .padding()
                .animation(.easeInOut)
            
            Text("\(Int(self.progress * 100))%")
                .font(Font.system(size: 16.0, weight: .bold))
                .multilineTextAlignment(.center)
            
            NavigationLink(
                destination: ExportView(),
                isActive: $isGenerationComplete,
                label: { Text("").hidden() }
            )
            
            Spacer()
        }
        .onAppear {
            self.flow.update(to: .progress)
            self.generateIcons()
        }
        
    }
    
    func generateIcons() {
        session.generateAssets(progress: { progress in
            self.progress = CGFloat(progress)
        }, completion: { _, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.isGenerationComplete = true
            }
        })
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ProgressView: View {
    let progress: CGFloat
    let color: Color
    let backgroundColor: Color
    
    init(progress: CGFloat, color: Color = .accentColor, backgroundColor: Color = .gray) {
        self.progress = progress
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        GeometryReader { metrics in
            ZStack(alignment: .leading) {
                Spacer()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(self.backgroundColor)
                
                Spacer()
                    .frame(minWidth: 0, maxWidth: metrics.size.width * self.progress, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                    .background(self.color)
            }
            .cornerRadius(metrics.size.height / 2.0)
        }
    }
}

struct GenerateProgressView_Previews: PreviewProvider {
    static var previews: some View {
        return GenerateProgressView()
    }
}
