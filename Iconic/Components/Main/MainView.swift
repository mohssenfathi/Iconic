//
//  MainView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 10/30/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI
import MobileCoreServices

struct MainView: View {
    @State var isGenerateViewPresented: Bool = false
    @State var isExportViewPresented: Bool = false
    @State var selectedSession: Session?
    @State var sessions: [Session] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sessions) { session in
                    SessionRow(session: session, selectionHandler: { _ in
                        self.isExportViewPresented = true
                    })
                    NavigationLink(
                        destination: ExportView().environmentObject(session),
                        isActive: self.$isExportViewPresented,
                        label: {
                            EmptyView()
                    })
                }
            }
            .navigationBarTitle("Icons")
            .navigationBarItems(trailing: newSessionButton)
        }
        .sheet(isPresented: $isGenerateViewPresented) {
            GenerateView().environmentObject(try! Session())
        }
        .onAppear {
            
            self.isGenerateViewPresented = false
            
            UINavigationBar.appearance().tintColor = UIColor.label
            UITableView.appearance().backgroundColor = UIColor.systemGroupedBackground
            UITableViewCell.appearance().backgroundColor = UIColor.systemGroupedBackground
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().tableFooterView = UIView()
            
            DispatchQueue.main.async {
                self.sessions = Session.all
            }
        }
    }
    
    var emptyView: some View {
        Button(action: {
            
        }, label: {
            Text("Create a new App Icon")
        })
        .padding()
    }
    
    var newSessionButton: some View {
        Button(action: {
            self.isGenerateViewPresented = true
        }, label: {
            Image(systemName: "plus")
                .padding()
        })
    }
}

struct SessionRow: View {
    let session: Session
    let selectionHandler: (Session) -> ()
    let dateFormatter: DateFormatter
    
    init(session: Session, selectionHandler: @escaping (Session) -> ()) {
        self.session = session
        self.dateFormatter = DateFormatter()
        self.selectionHandler = selectionHandler
        dateFormatter.dateStyle = .medium
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                self.selectionHandler(self.session)
            }, label: {
                
                ZStack {
                    HStack(spacing: 12.0) {
                        
                        VStack(alignment: .leading, spacing: 8.0) {
                            Text(dateFormatter.string(from: session.contents.lastModified))
                                .font(.system(size: 16.0, weight: .semibold))
                            Spacer()
                            Text("\(session.contents.appIconSet.assets.count) Assets")
                                .font(.system(size: 12.0, weight: .regular))
                                .foregroundColor(Color(UIColor.darkGray))
                            
                            Text(Array(session.devices).map { $0.title }.joined(separator: ", "))
                                .font(.system(size: 12.0, weight: .regular))
                                .foregroundColor(Color(UIColor.darkGray))
                        }
                        Spacer()
                        
                        Image(uiImage: session.thumbnail ?? UIImage())
                            .cornerRadius(4.0)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                }
                .padding()
            }).buttonStyle(CardCellStyle())
        }
        .background(Color.clear)
    }
}

struct CardCellStyle: ButtonStyle {
    
    let isSelectionEnabled: Bool
    
    init(isSelectionEnabled: Bool = true) {
        self.isSelectionEnabled = isSelectionEnabled
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12.0))
            .shadow(color: Color.black.opacity(0.1), radius: 4.0, x: 0, y: 4)
            .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            .scaleEffect((isSelectionEnabled && configuration.isPressed) ? 0.97 : 1.0)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
