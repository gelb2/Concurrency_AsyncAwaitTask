//
//  GlobalActorBootcamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/30.
//

import SwiftUI

//모델, 뷰모델 등 여러 클래스가 share할 무언가를 actor로 쓰면 좋다

//글로벌 액터는 뭘까
//앱 전체를 가로지르며 사용될 수 있는 액터
//만약 액터 안에 있는 메소드가 아닌 다른 메소드를 액터 안에서 쓰고 싶으면 어떻게 해야 할까. 예를 들면 뷰모델의 getData() 메소드는 MyNewDataManager 액터에 isolated 되지 않은 메소드인데...
//이럴때 글로벌액터를 사용할 수 있다.
//프로토콜을 보면 shared가 있는걸 알 수 있다. 싱글턴패턴인 것을 알 수 있다. 글로벌액터에선 이 싱글턴 인스턴스를 활용하는 것이 거의 필수적이다

//globalActor 어트리뷰트는 스트럭트, 클래스 둘 다 붙일 수 있다.
//
@globalActor struct MyFirstGlobalActor {
    static var shared = MyNewDataManager()
    
}

actor MyNewDataManager {
    
    func getDataFromDataBase() -> [String] {
        return ["one", "two", "three", "four", "five"]
    }
}

//이렇게 액터 어트리뷰트를 클래스나 스트럭트에 붙일 수도 있다
//@MainActor. 이러면 해당 클래스에서 하는 모든 일은 메인스레드로 isolated 되고
//@MyFirstGlobalActor // 이러면 해당 클래스에서 하는 모든 일은 MyFirstGlobalActor로 isolated 된다
//물론 이렇게 클래스 전체에 어트리뷰트를 붙인 경우, 어떤 메소드는 isolated 시키고 싶지 않으면 nonIsolated를 붙이면 된다
class GlobalActorBootcampViewModel: ObservableObject {
    
    //dataArray가 변하면 메인스레드에서 UI변경이 일어날 것이 명확하다. 어떻게 이 dataArray를 메인스레드로 isolate 시킬까?
    //MainActor도 글로벌엑터다
    @MainActor @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    
    //이렇게 어트리뷰트를 붙여주면 getData() 메소드는 MyFirstGlobalActor에서 run 된다
    //글로벌액터 어트리뷰트를 달아주면 실제 메소드를 호출할때 await를 걸 수 있다
    @MyFirstGlobalActor func getData() {
        
        
        
        //actor의 메소드는 async하다. actor니까
        
        Task {
            let data = await manager.getDataFromDataBase()
            
            
            //@MainActor 어트리뷰트가 붙은 값에 변화가 생기면
            //에러가 생긴다. Main actor-isolated property 'dataArray' can not be mutated from global actor 'MyFirstGlobalActor'
            //그럼 메인엑터에서 돌리게 mainActor.run을 추가해주면 된다
            await MainActor.run(body: {
                self.dataArray = data
            })
            
        }
    }
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
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
            await viewModel.getData()
        }
    }
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
