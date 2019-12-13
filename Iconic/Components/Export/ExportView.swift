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
    
    @EnvironmentObject var session: Session
    @EnvironmentObject var flow: GenerateFlow

    let isBackButtonHidden: Bool
    
    var groupedAssets: [String: [IconAsset]] {
        return session.appIconSet.assets.grouped(by: \.assetType.device.title)
    }
    
    init(isBackButtonHidden: Bool = false) {
        self.isBackButtonHidden = isBackButtonHidden
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
            
            exportButton
        }
        .navigationBarBackButtonHidden(isBackButtonHidden)
        .navigationBarTitle("Export")
        .onAppear {
            self.flow.update(to: .export)
            
            UITableView.appearance().backgroundColor = UIColor.systemGroupedBackground
            UITableViewCell.appearance().backgroundColor = UIColor.systemGroupedBackground
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().tableFooterView = UIView()
        }
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
    }
}
