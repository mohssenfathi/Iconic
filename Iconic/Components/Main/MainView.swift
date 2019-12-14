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
    @State var sessions: [Session] = []
    @State var selectedSession: Session.ID?
    
    var body: some View {
        NavigationView {
            Group {
                if sessions.isEmpty {
                    emptyView
                }
                else {
                    List {
                        ForEach(sessions) { session in
                            ZStack {
                                SessionRow(session: session, selectionHandler: { _ in
                                    self.selectedSession = session.id
                                })
                                NavigationLink(
                                    destination: self.exportView(session: session),
                                    tag: session.id,
                                    selection: self.$selectedSession) {
                                        EmptyView()
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationBarTitle("Icons")
            .navigationBarItems(trailing: newSessionButton)
            .sheet(isPresented: $isGenerateViewPresented, onDismiss: {
                self.sessions = Session.all.sorted(by: \Session.contents.lastModified)
            }, content: {
                return GenerateFlowView()
                    .environmentObject(try! Session())
            })
        }
        .onAppear {
            
            self.selectedSession = nil
            self.isExportViewPresented = false
            self.isGenerateViewPresented = false
            
            UINavigationBar.appearance().tintColor = UIColor.label
            UITableView.appearance().backgroundColor = UIColor.systemGroupedBackground
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().tableFooterView = UIView()
            UITableViewCell.appearance().backgroundColor = UIColor.systemGroupedBackground
            UITableViewCell.appearance().selectionStyle = .none
            
            DispatchQueue.main.async {
                self.sessions = Session.all.sorted(by: \Session.contents.lastModified)
            }
        }
    }
    
    func exportView(session: Session) -> some View {
        ExportView(isBackButtonHidden: false)
            .environmentObject(session)
            .environmentObject(GenerateFlow())
    }
    
    func delete(indexSet: IndexSet) {
        indexSet.forEach { index in
            self.sessions[index].delete()
        }
        sessions.remove(atOffsets: indexSet)
    }
    
    var emptyView: some View {
        VStack {
            Text("No Saved Icons")
                .font(Font.system(size: 14.0, weight: .medium))
                .foregroundColor(.secondary)
            
            Button(action: {
                self.isGenerateViewPresented = true
            }, label: {
                Text("New App Icon")
                    .font(Font.system(size: 14.0, weight: .medium))
                    .padding()
                    .foregroundColor(Color.secondary)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
            })
                .padding()
        }
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
    let timeFormatter: DateFormatter
    
    init(session: Session, selectionHandler: @escaping (Session) -> ()) {
        self.session = session
        self.dateFormatter = DateFormatter()
        self.timeFormatter = DateFormatter()
        self.selectionHandler = selectionHandler
        dateFormatter.dateStyle = .medium
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                self.selectionHandler(self.session)
            }, label: {
                
                ZStack {
                    HStack(spacing: 12.0) {
                        
                        VStack(alignment: .leading, spacing: 8.0) {
                            HStack(alignment: .bottom) {
                                Text(dateFormatter.string(from: session.contents.lastModified))
                                    .font(.system(size: 16.0, weight: .semibold))
                                Text(timeFormatter.string(from: session.contents.lastModified))
                                    .font(.system(size: 12.0, weight: .regular))
                                    .offset(x: 0, y: -1)
                            }
                            
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
                            .resizable()
                            .frame(width: 80, height: 80)
                            .cornerRadius(4.0)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.secondary, lineWidth: 0.5))

                        
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
