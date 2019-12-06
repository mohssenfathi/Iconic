//
//  GenerateView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 10/30/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI

/*
 <div>Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"     title="Flaticon">www.flaticon.com</a></div>
 */

struct Row: Hashable, Identifiable {
    var id: String { return title }
    let title: String
}

struct GenerateView: View {
    
    @EnvironmentObject var session: Session
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var devices: [Device] = [.iPhone, .iPad, .iMac, .appleTV, .appleWatch]
    @State var showImageSelectorModal: Bool = false
    
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
        NavigationView {
            VStack(spacing: 8) {
                Spacer()
                
                // Image Selection Button
                Button(action: {
                    self.showImageSelectorModal = true
                }, label: {
                    VStack {
                        if image == nil {
                            photoImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                        } else {
                            photoImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }

                    }.padding(photoInsets)
                })
                    .frame(width: imageButtonWidth, height: imageButtonWidth)
                    .clipShape(ImportShape(size: CGSize(width: imageButtonWidth, height: imageButtonWidth), cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1))
                    .foregroundColor(.primary)
                    .sheet(isPresented: $showImageSelectorModal) {
                        ImagePickerViewController { image in
                            self.image = image
                            self.showImageSelectorModal = false
                        }
                }
                
                Spacer()
                
                // Info Button
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
                
                Divider()
                
                // Device Selection
                VStack {
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
                
                Divider()
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                
                // Generate Button
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
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .bottom)
            .navigationBarItems(leading: cancelButton)
            .onAppear() {
                self.selections = [.iPhone, .iPad]
            }
        }
    }
    
    var cancelButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
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
    }
}
