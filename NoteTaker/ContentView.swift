//
//  ContentView.swift
//  NoteTaker
//
//  Created by Katie on 11/24/20.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HomeView: View {
    @ObservedObject var Notes = NotesList()
    @State var show = false
    @State var docID = ""
    @State var content = ""
    @State var color = ""
    @State var font = ""
    @State var remove = false
    var body: some View {
        ZStack{
            Rectangle().foregroundColor(.white).ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Notes").font(.largeTitle).foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        self.remove.toggle()
                    }) {
                        Image(systemName: self.remove ? "xmark.circle" : "trash").resizable().frame(width: 23, height: 23).foregroundColor(.white)
                    }
                }.padding().padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top).background(Color(UIColor.systemBlue))
                
                if self.Notes.notes.isEmpty {
                    if self.Notes.noData {
                        Spacer()
                        Text("No notes have been added yet.")
                        Spacer()
                    } else {
                        Spacer()
                        Indicator()
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack {
                            ForEach (self.Notes.notes) { note in
                                HStack(spacing: 15) {
                                    
                                    Button(action: {
                                        self.content = note.content
                                        self.color = note.color
                                        self.font = note.font
                                        self.docID = note.id
                                        self.show.toggle()
                                    }) {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text(note.content).lineLimit(1).foregroundColor(.black)
                                            ExDivider()
                                        }.padding(10)
                                    }
                                    
                                    if self.remove {
                                        Button(action: {
                                            let db = Firestore.firestore()
                                            db.collection("notes").document(note.id).delete()
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    
                                }.padding(.horizontal)
                            }
                        }
                    }.padding(.top)
                }
                Spacer()
                HStack {
                    Spacer()
                    Text("\(Notes.notes.count) Notes").font(.footnote).padding(.leading, 35)
                    Spacer()
                    Button(action: {
                        self.content = ""
                        self.color = ""
                        self.font = ""
                        self.docID = ""
                        self.show.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill").resizable().frame(width: 30, height: 30).foregroundColor(Color(UIColor.systemBlue))
                    }.padding(.trailing)
                }.frame(height: 80, alignment: .center).edgesIgnoringSafeArea(.all).border(Color.gray, width: 1)
            }.edgesIgnoringSafeArea(.all)
            
        }.sheet(isPresented: self.$show) {
            EditorView(docID: self.$docID, content: self.$content, color: self.$color, font: self.$font, show: self.$show)
        }.animation(.default)
    }
}

struct EditorView: View {
    @Binding var docID: String
    @Binding var content: String
    @Binding var color: String
    @Binding var font: String
    @Binding var show: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MultiLineTF(content: self.$content, color: self.$color, font: self.$font)
            
            Button(action: {
                self.show.toggle()
                self.saveData()
            }) {
                Text("Save").padding(.vertical).padding(.horizontal, 25).foregroundColor(.white)
            }.background(Color(UIColor.systemBlue)).clipShape(Capsule()).padding()
            
        }.edgesIgnoringSafeArea(.bottom)
    }
    
    func saveData() {
        let db = Firestore.firestore()
        if self.docID != "" {
            db.collection("notes").document(self.docID).updateData(["content": self.content]) { (err) in
                if err != nil {
                    print((err?.localizedDescription)!)
                    return
                }
            }
        } else {
            db.collection("notes").document().setData(["content": self.content, "color": "black", "font": "AppleColorEmoji"]) { (err) in
                if err != nil {
                    print((err?.localizedDescription)!)
                    return
                }
            }
        }
    }
}

struct MultiLineTF: UIViewRepresentable {
    func makeCoordinator() -> MultiLineTF.Coordinator {
        
        return MultiLineTF.Coordinator(parent1: self)
    }
    
    @Binding var content: String
    @Binding var color: String
    @Binding var font: String
    
    func makeUIView(context: UIViewRepresentableContext<MultiLineTF>) -> UITextView{
        
        let view = UITextView()
        
        if self.content != "" {
            
            view.text = self.content
            view.textColor = UIColor(hexString: self.color)
            view.font = UIFont(name: self.font, size: 18)
        }
        else{
            
            view.text = "Type Something"
            view.textColor = .gray
            view.font = .systemFont(ofSize: 18)
        }
        
        view.isEditable = true
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<MultiLineTF>) {
        
    }
    
    class Coordinator : NSObject,UITextViewDelegate{
        
        var parent : MultiLineTF
        
        init(parent1 : MultiLineTF) {
            
            parent = parent1
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            
            if self.parent.content == ""{
                
                textView.text = ""
                textView.textColor = .black
            }
            
        }
        
        func textViewDidChange(_ textView: UITextView) {
            
            self.parent.content = textView.text
        }
    }
}

struct ExDivider: View {
    let color: Color = .init(UIColor.lightGray)
    let width: CGFloat = 1
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: width)
            .edgesIgnoringSafeArea(.horizontal)
            .padding(.vertical, 3.0)
    }
}

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicator>) {
    }
}
