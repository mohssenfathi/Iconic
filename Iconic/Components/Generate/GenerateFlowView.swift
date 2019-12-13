//
//  GenerateFlowView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/6/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI
import Combine

class GenerateFlow: ObservableObject {
    
    let didChange = PassthroughSubject<GenerateFlow, Never>()
    
    var stage: Stage = .resourceSelection {
        didSet { didChange.send(self) }
    }
    
    enum Stage: Int {
        case resourceSelection
        case progress
        case export
    }
    
    func update(to stage: Stage) {
        self.stage = stage
    }
}

struct GenerateFlowView: View {
    
    struct UIState {
        let isCancelButtonEnabled: Bool
        let isDoneButtonEnabled: Bool
        let title: String
    }
    
    @EnvironmentObject var session: Session
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var uiState = UIState(isCancelButtonEnabled: true, isDoneButtonEnabled: false, title: "Select Image")
    @State var isDismissAlertPresented: Bool = false
    
    var flow: GenerateFlow = GenerateFlow()
    
    var body: some View {
        NavigationView {
            Group {
    //            HStack {
    //                cancelButton
    //                Spacer()
    //                doneButton
    //            }
    //            .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                
                GenerateView()
                    .environmentObject(session)
                    .environmentObject(flow)
                    .actionSheet(isPresented: $isDismissAlertPresented, content: {
                        self.saveActionSheet
                    })
            }
            .navigationBarTitle(Text(uiState.title), displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .onReceive(flow.didChange) { subject in
            self.updateState(subject.stage)
        }
    }
    
    func updateState(_ stage: GenerateFlow.Stage) {
        switch stage {
        case .resourceSelection:
            self.uiState = UIState(isCancelButtonEnabled: true, isDoneButtonEnabled: false, title: "Select Image")
        case .progress:
            self.uiState = UIState(isCancelButtonEnabled: false, isDoneButtonEnabled: false, title: "")
        case .export:
            self.uiState = UIState(isCancelButtonEnabled: false, isDoneButtonEnabled: true, title: "Export")
        }
    }
    
    var cancelButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            return Text("Cancel")
                .foregroundColor(.primary)
                .bold()
        })
            .isHidden(!uiState.isCancelButtonEnabled)
    }
    
    var doneButton: some View {
        Button(action: {
            self.isDismissAlertPresented = true
        }, label: {
            return Text("Done")
                .foregroundColor(.primary)
                .bold()
        })
            .isHidden(!uiState.isDoneButtonEnabled)
    }
    
    
    var saveActionSheet: ActionSheet {
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
    }
}

struct GenerateFlowView_Previews: PreviewProvider {
    static var previews: some View {
        return GenerateFlowView()
            .environmentObject(try! Session())
    }
}
