//
//  ContentView.swift
//  NoteTaker
//
//  Created by Katie on 11/24/20.
//

import SwiftUI
import Combine
import FirebaseFirestore

// CONTENT VIEW
struct ContentView: View {
    var body: some View {
        NavigationView {
            HomeView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// HOME VIEW
struct HomeView: View {
    init(){ // INITIALIZE NAVBAR APPEARANCE
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    @ObservedObject var noteDetails = NoteDetails()
    @ObservedObject var Notes = NotesList()
    @State var show = false
    
    
    var body: some View {
        
       

            VStack {
                NavigationLink(destination: EditorView(docID: $noteDetails.docID, title: $noteDetails.title, content: $noteDetails.content, color: $noteDetails.color, font: $noteDetails.font, show: $show), isActive: $show) { EmptyView() }
                if self.Notes.notes.isEmpty {
                    if self.Notes.noData { // NO NOTES HAVE BEEN CREATED YET
                        Spacer()
                        Text("No Notes Yet")
                        Spacer()
                    } else { // WAITING TO FETCH NOTES
                        Spacer()
                        Indicator()
                        Spacer()
                    }
                } else {
                    
                    List {
                        Section {
                        ForEach (self.Notes.notes) { note in
                            VStack (alignment: .leading){
                                Text(note.title).bold().lineLimit(1).frame(alignment: .leading).padding(.top, 5).font(.body)
                                Text(note.content).lineLimit(1).frame(alignment: .leading).padding(.bottom, 5)
                            }.onTapGesture {
                                self.noteDetails.title = note.title
                                self.noteDetails.content = note.content
                                self.noteDetails.color = note.color
                                self.noteDetails.font = note.font
                                self.noteDetails.docID = note.id
                                self.show = true
                            }
                        }.onDelete(perform: deleteItems)
                        }
                    }.listStyle(InsetGroupedListStyle())
                    .environment(\.horizontalSizeClass, .regular)
                }
                Spacer()
                HStack {
                    Spacer()
                    Text((Notes.notes.count == 0) ? "0 Notes" : (Notes.notes.count == 1) ? "1 Note" : "\(Notes.notes.count) Notes").font(.footnote)
                    Spacer()
                }.frame(height: 80, alignment: .center).edgesIgnoringSafeArea(.horizontal)
            }.edgesIgnoringSafeArea(.bottom).navigationBarTitle("Notes").navigationBarItems(trailing: VStack{
                
                EditButton().padding(.top, 20)
                Text("Test")
//                Button(action: {
//                    self.noteDetails.title = ""
//                    self.noteDetails.content = ""
//                    self.noteDetails.color = ""
//                    self.noteDetails.font = ""
//                    self.noteDetails.docID = ""
//                    self.show = true
//                }) {Image(systemName: "plus").foregroundColor(.blue).font(.headline).padding(.top, 8)}
            })
       
    }
    
    func deleteItems(at offsets: IndexSet) {
        let db = Firestore.firestore()
        for i in 0..<Notes.notes.count{
            if offsets.contains(i) {
                db.collection("notes").document(Notes.notes[i].id).delete()
            }
        }
        Notes.notes.remove(atOffsets: offsets)
    }
}
