//
//  EditorView.swift
//  NoteTaker
//
//  Created by Katie on 11/24/20.
//

import SwiftUI
import FirebaseFirestore

struct EditorView: View {
    @Binding var docID: String
    @Binding var title: String
    @Binding var content: String
    @Binding var color: String
    @Binding var font: String
    @Binding var show: Bool
    @State var showPanel = false
    @ObservedObject var keyboardResponder = KeyboardResponder()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let nc = NotificationCenter.default
    
    var body: some View {
        
        
        VStack {
            
            TextField("Title", text: $title).font(.largeTitle).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.vertical)
            
            TextEditor(text: $content).padding(.all).foregroundColor(fontColors[self.color]).font(fontStyles[self.font]).onTapGesture {
                nc.post(name: Notification.Name("KeyboardAppeared"), object: nil)
            }
            
            HStack {
                Spacer()
                Button(action: {
                    self.hideKeyboard()
                    nc.post(name: Notification.Name("KeyboardHidden"), object: nil)
                }) {
                    Text("Done").foregroundColor(.gray).font(.headline)
                }
                
                
                Spacer()
                
                Button(action: {
                    self.showPanel = true
                }) {
                    Image(systemName: "textformat").font(.headline).foregroundColor(.white).padding(.all, 9)
                }.background(Color.green).clipShape(Circle())
                
                Spacer()
                
                Button(action: {
                    self.show.toggle()
                    self.saveData()
                }) {
                    Text("Save").foregroundColor(Color(UIColor.systemBlue)).font(.headline)
                }
                Spacer()
            }.edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true).navigationBarItems(leading:
                Button(action: {
                        self.show = false
                        self.presentationMode.wrappedValue.dismiss()
                    }){HStack {
                        Image(systemName: "arrow.left.circle")
                        Text("Go Back")
                    }}
            ).padding(.bottom, keyboardResponder.currentHeight)
            
        }.keyboardVisibility().sheet(isPresented: $showPanel){
            VStack {
                Spacer()
                ScrollView(.horizontal){
                    
                    HStack (spacing: 20) {
                        Text("Large Title").font(.largeTitle).onTapGesture {
                            self.font = "largetitle"
                            self.showPanel = false
                        }
                        Text("Title").font(.title).onTapGesture {
                            self.font = "title"
                            self.showPanel = false
                        }
                        Text("Headline").font(.headline).onTapGesture {
                            self.font = "headline"
                            self.showPanel = false
                        }
                        Text("Subheading").font(.subheadline).onTapGesture {
                            self.font = "subheadline"
                            self.showPanel = false
                        }
                        Text("Body").font(.body).onTapGesture {
                            self.font = "body"
                            self.showPanel = false
                        }
                        Text("Caption").font(.caption).onTapGesture {
                            self.font = "caption"
                            self.showPanel = false
                        }
                    }
                }
                Spacer()
                HStack (spacing: 20) {
                    Circle().frame(width: 30, height: 30).foregroundColor(Color.black).onTapGesture {
                        self.color = "black"
                        self.showPanel = false
                    }
                    Circle().frame(width: 30, height: 30).foregroundColor(Color.gray).onTapGesture {
                        self.color = "gray"
                        self.showPanel = false
                    }
                    Circle().frame(width: 30, height: 30).foregroundColor(Color.blue).onTapGesture {
                        self.color = "blue"
                        self.showPanel = false
                    }
                    Circle().frame(width: 30, height: 30).foregroundColor(Color.green).onTapGesture {
                        self.color = "green"
                        self.showPanel = false
                    }
                    Circle().frame(width: 30, height: 30).foregroundColor(Color.purple).onTapGesture {
                        self.color = "purple"
                        self.showPanel = false
                    }
                    Circle().frame(width: 30, height: 30).foregroundColor(Color.pink).onTapGesture {
                        self.color = "pink"
                        self.showPanel = false
                    }
                    Circle().frame(width: 30, height: 30).foregroundColor(Color.red).onTapGesture {
                        self.color = "red"
                        self.showPanel = false
                    }
                }.padding(.top)
                Spacer()
                
            }.padding(.all)
        }
    }
    
    func keyboardHidden() {
        
    }
    
    func saveData() {
        let db = Firestore.firestore()
        if self.docID != "" {
            db.collection("notes").document(self.docID).updateData(["title": self.title, "content": self.content, "font": self.font, "color": self.color]) { (err) in
                if err != nil {
                    print((err?.localizedDescription)!)
                    return
                }
            }
        } else {
            db.collection("notes").document().setData(["title": self.title, "content": self.content, "color": self.color, "font": self.font]) { (err) in
                if err != nil {
                    print((err?.localizedDescription)!)
                    return
                }
            }
        }
    }
}


struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(docID: .constant(""), title: .constant(""), content: .constant(""), color: .constant(""), font: .constant(""), show: .constant(true))
    }
}

