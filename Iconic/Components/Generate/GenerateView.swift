//
//  GenerateView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 10/30/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI

struct Row: Hashable, Identifiable {
    var id: String { return title }
    let title: String
}

struct GenerateView: View {
    
    @EnvironmentObject var session: Session
    @EnvironmentObject var flow: GenerateFlow
    @State var devices: [Device] = [.iPhone, .iPad, .mac, .appleWatch, .carPlay]
    @State var showImageSelectorModal: Bool = false
    var destination: some View = EmptyView()
    
    @State var selections: [Device] = [] {
        didSet {
            // Generate assets for selected devices, plus required ones
            var set = Set<Device>(selections)
            set.insert(.appStore)
            session.devices = set
        }
    }
    
    @State var image: UIImage? {
        didSet {
            guard let image = image else { return }
            session.image = image
        }
    }
    
    let imageButtonWidth: CGFloat = 160.0
    
    var generateButtonColor: Color {
        return isGenerateDisabled ? Color.gray : Color.primary
    }
    
    var isGenerateDisabled: Bool {
        return image == nil || selections.isEmpty
    }
    
    var hasImage: Bool {
        return image != nil
    }
    
    var photoImage: Image {
        guard let image = self.image else {
            return Image("add_image")
        }
        return Image(uiImage: image)
            .renderingMode(.original)
    }
    
    var photoInsets: EdgeInsets {
        guard image == nil else {
            return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
        return EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    Spacer()
                    self.imageSelectionButton
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height * 0.3)
                    Spacer()
                    Divider()
                    self.deviceSelectionView
                    Divider().padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                    Spacer()
                    self.generateButton
                    Spacer(minLength: 10.0)
                }
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .background(Color(UIColor.systemGroupedBackground))
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear() {
            self.flow.update(to: .resourceSelection)
            self.selections = [.iPhone, .iPad]
        }
    }
    
    
    var imageSelectionButton: some View {
        Button(action: {
            self.showImageSelectorModal = true
        }, label: {
            VStack {
                if image == nil {
                    photoImage
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    photoImage
                        .resizable()
                        .aspectRatio((image?.size.width ?? 1.0) / (image?.size.height ?? 1.0), contentMode: .fill)
                }

            }.padding(photoInsets)
        })
            .frame(width: imageButtonWidth, height: imageButtonWidth)
            .foregroundColor(.primary)
            .background(Color(UIColor.systemBackground))
            .clipShape(ImportShape(size: CGSize(width: imageButtonWidth, height: imageButtonWidth), cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1))
            .sheet(isPresented: $showImageSelectorModal) {
                ImagePickerViewController { image in
                    self.image = image
                    self.showImageSelectorModal = false
                }
        }
    }
    
    var infoButton: some View {
        HStack {
            Spacer()
            Button(action: {
                
            }, label: {
                Image(systemName: "info.circle")
                    .resizable()
                    .foregroundColor(.primary)
                    .frame(width: 20, height: 20)
            })
        }.padding(EdgeInsets(top: 0, leading: 30, bottom: 15, trailing: 26))
        
    }
    
    var deviceSelectionView: some View {
        VStack(spacing: 12) {
            ForEach(self.devices, id: \.self) { device in
                MultipleSelectionRow(
                    title: device.title,
                    image: device.image,
                    isSelected: self.selections.contains(device)) {
                        if self.selections.contains(device) {
                            self.selections.removeAll(where: { $0 == device })
                        }
                        else {
                            self.selections.append(device)
                        }
                }
            }
        }
        .padding()
        .foregroundColor(.primary)
        .background(Color(UIColor.systemBackground))
    }
    
    var generateButton: some View {
        NavigationLink(
            "Generate Assets",
            destination: GenerateProgressView()
        )
            .padding()
            .font(.system(size: 16.0, weight: .bold))
            .frame(width: nil, height: 40)
            .foregroundColor(generateButtonColor)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(generateButtonColor, lineWidth: 2))
            .disabled(isGenerateDisabled)
    }
}

struct ImportShape: Shape {
    private let size: CGSize
    private let cornerRadius: CGFloat
    init(size: CGSize, cornerRadius: CGFloat) {
        self.size = size
        self.cornerRadius = cornerRadius
    }
    func path(in rect: CGRect) -> Path {
        return Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius)
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var image: Image
    var isSelected: Bool
    var action: () -> Void
    
    var checkImage: some View {
        let img = isSelected ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "circle")
        return img
            .resizable()
            .frame(width: 23, height: 23)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
    }
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding(4)
                
                Text(self.title)
                    .font(.system(size: 14.0, weight: .semibold))
                
                Spacer()
                
                self.checkImage
            }
        }
    }
}


struct GenerateView_Previews: PreviewProvider {
    
    static var previews: some View {
        GenerateView()
            .environmentObject(try! Session())
            .environmentObject(GenerateFlow())
    }
}
