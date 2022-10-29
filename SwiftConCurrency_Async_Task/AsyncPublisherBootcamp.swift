//
//  AsyncPublisherBootcamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/30.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    @Published var myDate: [String] = []
    
    func addData() async {
        myDate.append("apple")
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        myDate.append("banana")
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myDate.append("orange")
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myDate.append("grape")
    }
}

class AsyncPublisherBootcampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func start() async {
        await manager.addData()
    }
    
    //보통은 이렇게 바인딩용 함수를 둘 건데...
    private func addSubscribers() {
        
        //콤바인과 async,await를 같이 쓴다는게 생각보다 쉽지는 않을 것이다. 그걸 염두해야 한다
        //그럼 콤바인 파이프라인 스러운 처리를 네이티브한 concurrency way인 async await로는 어떻게 만들어야 할까?
        //애플은 콤바인으로부터 published된걸 async,await로 전환할 수 있는 메소드를 만들어놨다. 그게 asyncPublisher다
        
        Task {
            
            await MainActor.run(body: {
                self.dataArray = ["One"]
            })
            
            //values 다음에 .dropFirst, .map() 같은 것도 추가로 부를 수도 있다
            for await value in manager.$myDate.values {
                await MainActor.run(body: {
                    self.dataArray = value
                })
                break
            }
            
            //얘는 왜 안불릴까?
            //그건 for await value in manager.$myDate.values 루프문이 values값이 "도착하길" 기다리기 때문이다. asyncPublisher는 그 성격상 컴파일러가 "이 서브스크라이빙이 언제 시작될지, 언제 끝날지"를 알 수가 없다. 그래서 values가 도착하는걸 기다리고자 task가 suspended 되는 상태가 된다.
            //루프의 } 이전에 break를 넣으면 아래의 await MainActor 가 불리는걸 볼 수 있다.
            await MainActor.run(body: {
                self.dataArray = ["Two"]
            })
            
            //asyncPublisher는 asyncSequence, asyncStream, 애플이 swift.org에 3월에 발표한 introducing async Algoritism와 같이 보는 것이 좋다
            
        }
        
        
        
        
        
        /*
        manager.$myDate //이 바인딩 가능한 변수를
            .receive(on: DispatchQueue.main, options: nil) //메인스레드에서 뭔가를 하게끔 받을거고
            .sink { dataArray in
                self.dataArray = dataArray
            }
            .store(in: &cancellables) //dispose 시킬 것이다?
        */
    }
}

struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

struct AsyncPublisherBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootcamp()
    }
}
