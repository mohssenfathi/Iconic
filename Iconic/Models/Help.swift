//
//  Help.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/16/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import SwiftUI

enum HelpItem: ExpandableItem, Identifiable, Hashable {
    typealias V = AnyView
    
    case text(title: String, detail: String)
    case view(title: String, view: AnyView)
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .text(let title, _),
             .view(let title, _):
            return title
        }
    }
    
    var view: AnyView {
        switch self {
        case .text(_, let detail):
            return AnyView(
                Text(detail)
                    .font(Font.system(size: 14.0, weight: .regular))
            )
        case .view(_, let view):
            return view
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HelpItem, rhs: HelpItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Help {
    
    static let generateHelpItems: OrderedDictionary<String, [HelpItem]> = [
        
        "General" : [
            HelpItem.view(
                title: "How do I create an app icon set?",
                view: AnyView(
                    VStack(alignment: .leading, spacing: 12.0) {
                        Text("To generate a new app icon set:")
                        
                        Group {
                            HStack(alignment: .top) {
                                Text("1.")
                                Text("Select an image from iCloud or your Photo Library by tapping the photo button (pictured below). The image must be 1024px x 1024px minimum.")
                            }
                            
                            HStack() {
                                Spacer()
                                Image(uiImage: #imageLiteral(resourceName: "add_image.pdf"))
                                    .resizable()
                                    .frame(width: 35.0, height: 30.0, alignment: .center)
                                Spacer()
                            }
                            
                            HStack(alignment: .top) {
                                Text("2.")
                                Text("Check the supported devices in the list beneath the selected photo.")
                            }
                            
                            HStack(alignment: .top) {
                                Text("3.")
                                Text("Select \"Generate Assets\"")
                            }
                        }.font(Font.system(size: 14.0, weight: .regular))
                    }
                )
            ),
            
                
            HelpItem.text(
                title: "How do I save an app icon set I created in the app?",
                detail: "After generation is complete you will be given the option to save your session before closing the export view. Saved sessions will be available on the main page of the app and can be exported again."
            ),
            
            HelpItem.text(
                title: "Can I edit an icon set I have already created?",
                detail: "At this time it is not possible to edit an icon set previously created. To export new assets, create a new session using the same input image as the one previously used."
            ),
        ],
        "Input" : [
            HelpItem.text(
                title: "Which file formats are supported?",
                detail: "Input images must be supplied as a JPEG, PNG, or PDF with no transperancy. Images must also be greater than 1024px x 1024px in size."
            ),
            
            HelpItem.text(
                title: "Do I need to add a corner radius to my input image?",
                detail: "No. A mask will be applied to your app icon's once they are imported into Xcode. Supplying a square image is expected."
            ),
        ],
        
        "Output" : [
            HelpItem.text(
                title: "In what format are the generated icons output?",
                detail: "App icons are packaged as an .appiconset folder. With this format you can drop your icons directly into the Assets.xcassets folder in your project without needing to manually assign each asset. Individual assets are contained within the exported folder named AppIcon.appiconset."
            )
        ],
        
        "Support" : [
            HelpItem.text(
                title: "Which devices are supported?",
                detail: """
                Iconic currently supports the following devices:

                • Apple Watch
                • CarPlay
                • iPhone
                • iPad
                • Mac
                """
            ),
            
            HelpItem.text(
                title: "What platforms does Iconic support?",
                detail: """
                Iconic has been tested using Xcode 11+ and the following OS's:
                
                • iOS / tvOS 13+
                • macOS 10.15+
                • watchOS 6+
                
                It can be used to generate assets for all supported devices on these platforms without any modification. Older platforms can be used, but may require some modification to the generated icon set.
                """
            ),
            
            HelpItem.view(
                title: "My question is not listed above.",
                view: AnyView(
                    VStack(spacing: 12) {
                        Text("For more information see Apple's Human Interface Guidelines regarging App Icons.")
                        Button(action: {
                            Links.open(link: .appIconHIG)
                        }, label: {
                            Text("App Icon HIG")
                                .padding()
                                .background(Color(UIColor.systemBlue))
                                .foregroundColor(Color(UIColor.systemBackground))
                                .cornerRadius(6.0)
                        })
                    }
                )
            )
        ]
        
    ]
    
}

struct GenerateHelpView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            ExpandableItemView(items: Help.generateHelpItems)
                .navigationBarTitle("Help")
                .navigationBarItems(trailing: doneButton)
        }
    }
    
    
    var doneButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
                .bold()
                .foregroundColor(.primary)
        })
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        return GenerateHelpView()
    }
}
