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
    
    enum Modal {
        case photoSelector
        case fileSelector
        case help
        case none
    }
    
    @EnvironmentObject var flow: GenerateFlow
    @State var devices: [Device] = [.iPhone, .iPad, .mac, .appleWatch, .carPlay]
    @State var error: Error?
    
    @State var showModal: Bool = false
    @State var showDocumentSelectorAlert: Bool = false
    @State var modal: Modal = .none
    
    var session: Session { flow.session }
    var destination: some View = EmptyView()
    
    @State var selections: [Device] = [.iPhone, .iPad, .appStore] {
        didSet {
            // Generate assets for selected devices, plus required ones
            var set = Set<Device>(selections)
            set.insert(.appStore)
            session.devices = set
        }
    }
    
    @State var image: UIImage? {
        didSet {
            self.error = session.validate(image: image)
            guard let image = image else { return }
            session.image = image
            thumbnail = image.resize(to: CGSize(width: 50, height: 50))
        }
    }
    
    @State var thumbnail: UIImage?
    let imageButtonWidth: CGFloat = 160.0
    
    var generateButtonColor: Color {
        return isGenerateDisabled ? Color.gray : Color.primary
    }
    
    var isGenerateDisabled: Bool {
        guard error == nil else { return true }
        return image == nil || selections.isEmpty
    }
    
    var hasImage: Bool {
        return image != nil
    }
    
    var photoInsets: EdgeInsets {
        return EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    Group {
                        Spacer()
                        
                        ZStack {
                            self.currentImageButton
                            self.selectImageButton
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height * 0.3)
                        
                        if self.error != nil {
                            self.errorText
                        }
                        self.helpButton
                    }
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
                .actionSheet(isPresented: self.$showDocumentSelectorAlert, content: {
                    self.documentSelectionAlertSheet
                })
                .sheet(isPresented: self.$showModal, content: {
                    if self.modal == .photoSelector {
                        ImagePickerViewController { image in
                            self.image = image
                            self.showModal = false
                            self.modal = .none
                        }
                    } else if self.modal == .fileSelector {
                        DocumentPickerViewController { image in
                            self.image = image
                            self.showModal = false
                            self.modal = .none
                        }
                    } else if self.modal == .help {
                        GenerateHelpView()
                    } else {
                        Text("")
                    }
                })
            }
        }
        .onAppear() {
            self.showModal = false
            self.showDocumentSelectorAlert = false
            self.modal = .none
            self.flow.update(to: .resourceSelection)
            self.session.devices = Set<Device>(self.selections)
        }
    }
    
    var errorText: some View {
        VStack(alignment: .center) {
         Text((error as? SessionError)?.localizedDescription ?? "")
            .foregroundColor(Color(UIColor.systemRed))
            .font(Font.system(size: 14.0, weight: .regular))
            .lineLimit(nil)
            .multilineTextAlignment(.center)
        }.padding()
    }
    
    var currentImageButton: some View {
        Button(action: {
            self.showDocumentSelectorAlert = true
        }, label: {
            Image(uiImage: image ?? UIImage())
            .renderingMode(.original)
            .resizable()
            .aspectRatio((image?.size.width ?? 1.0) / (image?.size.height ?? 1.0), contentMode: .fill)
        })
            .frame(width: imageButtonWidth, height: imageButtonWidth)
            .foregroundColor(.primary)
            .background(Color(UIColor.systemBackground))
            .clipShape(ImportShape(size: CGSize(width: imageButtonWidth, height: imageButtonWidth), cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1))
    }
    
    var selectImageButton: some View {
        Button(action: {
            self.showDocumentSelectorAlert = true
        }, label: {
            if image == nil {
                Image("add_image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.primary)
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.2.circlepath.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: nil, alignment: .bottomTrailing)
                            .padding(EdgeInsets(top: 12, leading: 12, bottom: 8, trailing: 8))
                            .foregroundColor((thumbnail?.isDark ?? false) ? Color(UIColor.systemBackground).opacity(0.8) : Color.primary.opacity(0.8))
                    }
                }
                .frame(width: imageButtonWidth, height: imageButtonWidth)
            }
        })
    }
    
    var helpButton: some View {
        HStack {
            Spacer()
            Button(action: {
                self.modal = .help
                self.showModal = true
            }, label: {
                Image(systemName: "questionmark.circle")
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
    
    var documentSelectionAlertSheet: ActionSheet {
        ActionSheet(
            title: Text("Select Image From"),
            message: nil,
            buttons: [
                Alert.Button.default(Text("Photo Library"), action: {
                    self.modal = .photoSelector
                    self.showModal = true
                }),
                Alert.Button.default(Text("Files"), action: {
                    self.modal = .fileSelector
                    self.showModal = true
                }),
                Alert.Button.cancel(Text("Cancel"))
        ])
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
            .environmentObject(GenerateFlow())
    }
}

