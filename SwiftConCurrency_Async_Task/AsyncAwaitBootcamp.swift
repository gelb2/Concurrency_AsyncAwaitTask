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
    
    //async await task를 쓴다고 해당 코드가 반드시 메인스레드 이외의 다른 스레드에서 돌아간다, 혹은 그 반대로 메인스레드 이외에서 돌아가던 것이 백그라운드 스레드 등 다른 스레드에서 돌아간다는 것을 의미하는 것이 아니다.다른 처리를 추가로 더 해줘야 한다. 예를 들면, UI고치는 것은 MainActor.run 블록 안에서 해주는 것
    //addAuthor1은 어떤 순서로 돌아갈까? await가 있는 부분은 리스폰스가 올 때까지 기다렸다가 위에서부터 아래로 순서대로 진행
    func addAuthor1() async {
        let author1 = "authro1 :\(Thread.current) "
        self.dataArray.append(author1)
        
        
//        try? await doSomething()
        
        //Task 2초 슬립
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "authro2 :\(Thread.current) "
        
        //메인스레드에서 돌릴 것을 명령
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            let author3 = "authro3 :\(Thread.current) "
            self.dataArray.append(author3)
        })
        
        await addSomething()
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let something1 = "something1 :\(Thread.current) "
        
        //메인스레드에서 돌릴 것을 명령
        await MainActor.run(body: {
            self.dataArray.append(something1)
            
            let something2 = "something2 :\(Thread.current) "
            self.dataArray.append(something2)
        })
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
            Task {
                await viewModel.addAuthor1()
                await viewModel.addSomething()
                
                //위에서 await로 기다릴것을 명령했으므로 아래 finalText, append는 가장 마지막에 불린다
                let finalText = "final : \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
            
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

struct AsyncAwaitBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootcamp()
    }
}
