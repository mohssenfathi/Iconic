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
    @EnvironmentObject var session: Session
    @State var isShareSheetVisible: Bool = false
    @State var isDismissAlertPresented: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let isBackButtonHidden: Bool
    
    init(isBackButtonHidden: Bool = false) {
        self.isBackButtonHidden = isBackButtonHidden
    }
    
    var groupedAssets: [String: [IconAsset]] {
        return session.appIconSet.assets.grouped(by: \.assetType.device.title)
    }
    
    var doneButton: some View {
        Button(action: {
            self.isDismissAlertPresented = true
        }, label: {
            Text("Done").bold()
        })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(uiImage: session.image)
                    .resizable()
                    .frame(width: 150, height: 150)
                    .clipShape(ImportShape(size: CGSize(width: 150, height: 150), cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1))
            }.padding()
            
            HStack {
                Text("Generated \(session.appIconSet.images.count) assets")
                    .padding()
                    .font(.system(size: 14.0))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            Divider()
            
            List {
                ForEach(Array(groupedAssets.keys).sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(self.groupedAssets[key] ?? []) {
                            AssetImageRow(asset: $0)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            
            Divider()
            
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
                    ActivityViewController(activityItems: [self.session.url])
            }
            
        }
        .navigationBarBackButtonHidden(isBackButtonHidden)
        .navigationBarItems(trailing: doneButton)
        .navigationBarTitle("Export")
        .actionSheet(isPresented: $isDismissAlertPresented, content: { () -> ActionSheet in
            ActionSheet(
                title: Text("Save Session"),
                message: Text("Would you like to save these assets for later?"),
                buttons: [
                    Alert.Button.default(Text("Save"), action: {
                        try? self.session.save()
                        self.presentationMode.wrappedValue.dismiss()
                    }),
                    Alert.Button.destructive(Text("Delete"), action: {
                        self.session.delete()
                        self.presentationMode.wrappedValue.dismiss()
                    }),
                    Alert.Button.cancel(Text("Cancel"))
            ])
        })
            .onAppear {
                UITableView.appearance().backgroundColor = UIColor.systemGroupedBackground
                UITableViewCell.appearance().backgroundColor = UIColor.systemGroupedBackground
                UITableView.appearance().separatorStyle = .none
                UITableView.appearance().tableFooterView = UIView()
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
    }
}
