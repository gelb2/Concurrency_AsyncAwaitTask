//
//  ContentView.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/28.
//

import SwiftUI

class TaskBottoCampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    
    func fetchImage() async {
        do {
            guard let url = URL(string: "") else { return }
        } catch {
            
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
