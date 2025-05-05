import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "folder.badge.plus")
                .resizable()
                .frame(width: 100, height: 80)
                .foregroundColor(.blue)
            
            Text("Folder Preview")
                .font(.title)
                .padding()
            
            Text("This app installs a Quick Look extension for previewing folders.")
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Just press the spacebar on any folder in Finder to preview its contents.")
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(width: 400, height: 300)
    }
}
