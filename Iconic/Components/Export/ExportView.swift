//
//  ExportView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 11/25/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI
import UIKit

struct ExportView: View {
    
    @State var isShareSheetVisible: Bool = false
    
    @EnvironmentObject var flow: GenerateFlow
    
    let isBackButtonHidden: Bool
    let dateFormatter: DateFormatter
    let timeFormatter: DateFormatter
    
    var session: Session { flow.session }
    
    var groupedAssets: [String: [IconAsset]] {
        return session.appIconSet.assets.grouped(by: \.assetType.device.title)
    }
    
    init(isBackButtonHidden: Bool = false) {
        self.isBackButtonHidden = isBackButtonHidden
        self.dateFormatter = DateFormatter()
        self.timeFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.titleField
                
                HStack {
                    self.imageView(width: geometry.size.height * 0.25 - 40)
                    
                    VStack(alignment: .leading) {
                        Text("\(self.session.appIconSet.images.count) Assets")
                            .bold()
                            .font(.system(size: 16.0))
                            .multilineTextAlignment(.leading)
                            .padding()
                        
                        Text("Devices")
                            .underline()
                            .font(.system(size: 12.0))
                            .multilineTextAlignment(.leading)
                            .padding([.leading])
                        
                        ForEach(Array(self.session.devices)) {
                            Text("• \($0.title)")
                                .font(.system(size: 12.0))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.secondary)
                                .padding([.leading])
                        }
                    }
                    
                    Spacer()
                }
                .padding([.leading, .trailing])
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height * 0.22)
                
                HStack {
                     Text("Created \(self.dateFormatter.string(from: self.session.contents.dateCreated)) at \(self.timeFormatter.string(from: self.session.contents.dateCreated))")
                        .padding()
                        .font(.system(size: 12.0))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                
                Divider()
                
                List {
                    ForEach(Array(self.groupedAssets.keys).sorted(), id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(self.groupedAssets[key] ?? []) {
                                AssetImageRow(asset: $0)
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                
                Divider()
                
                self.exportButton
            }
        }
        .navigationBarBackButtonHidden(isBackButtonHidden)
        .navigationBarHidden(isBackButtonHidden)
        .onAppear {
            self.flow.update(to: .export)
            
            UITableView.appearance().backgroundColor = UIColor.systemGroupedBackground
            UITableViewCell.appearance().backgroundColor = UIColor.systemGroupedBackground
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().tableFooterView = UIView()
        }
        .onDisappear {
            try? self.session.save()
        }
    }
    
    var titleField: some View {
        Group {
            HStack {
                ZStack {
                    TextField("App Icon Name", text: $flow.session.title, onEditingChanged: { changed in
                        
                    }, onCommit: {
                        
                    })
                    .keyboardType(.default)
                    .font(Font.system(size: 30.0, weight: .bold))
                
                    HStack {
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.secondary)
                            .disabled(true)
                    }.padding()
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 4))
                .background(Color(UIColor.systemGroupedBackground).opacity(0.75))
                .cornerRadius(10.0)
            }
            .padding()
        }
    }
    
    func imageView(width: CGFloat) -> some View {
        Image(uiImage: self.session.image)
            .resizable()
            .aspectRatio(self.session.image.size.width / self.session.image.size.height, contentMode: .fill)
            .frame(width: width, height: width)
            .clipShape(ImportShape(size: CGSize(width: width, height: width), cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1))
    }
    
    var exportButton: some View {
        Button(action: {
            self.isShareSheetVisible = true
        }, label: {
            HStack(spacing: 8) {
                Text("Export")
                    .font(Font.system(size: 18.0, weight: .bold))
                    .frame(width: nil, height: 40)
                    .foregroundColor(Color.primary)
                
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color.primary)
                    .font(Font.system(size: 14.0, weight: .semibold))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
            }
            .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
        })
            .sheet(isPresented: $isShareSheetVisible) {
                ActivityViewController(activityItems: [self.session.iconSetUrl])
        }
    }
}

struct AssetImageRow: View {
    let asset: IconAsset
    
    init(asset: IconAsset) {
        self.asset = asset
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                
            }, label: {
                ZStack {
                    VStack(alignment: .leading, spacing: 12.0) {
                        
                        HStack(spacing: 12.0) {
                            Text("\(asset.assetType.description) @ \(asset.scaleString)")
                                .font(.system(size: 16.0, weight: .semibold))
                            Spacer()
                            Text("\(asset.sizeString)")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Text(asset.filename)
                            .font(.system(size: 12.0, weight: .regular))
                            .foregroundColor(Color.gray)
                    }
                    .padding()
                }
            })
                .buttonStyle(CardCellStyle(isSelectionEnabled: false))
        }
        .background(Color.clear)
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
            .environmentObject(GenerateFlow())
    }
}
