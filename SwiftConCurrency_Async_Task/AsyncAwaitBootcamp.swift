//
//  AsyncAwaitBootcamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/28.
//

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("title1 :\(Thread.current) ")
        }
    }
    
    func addTitle2() {
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "title2 :\(Thread.current) "
            DispatchQueue.main.async {
                self.dataArray.append(title)
                let title3 = "title3 :\(Thread.current) "
                self.dataArray.append(title3)
            }
        }
    }
}

struct AsyncAwaitBootcamp: View {
    
    @StateObject private var viewModel = AsyncAwaitBootcampViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            viewModel.addTitle1()
            viewModel.addTitle2()
        }
    }
}

struct AsyncAwaitBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootcamp()
    }
}
