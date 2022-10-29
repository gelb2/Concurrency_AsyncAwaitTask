//
//  ActorsBootCamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/29.
//

import SwiftUI

//액터가 해결하고 있는 문제는 뭘까?
//데이터레이싱. 경쟁상황 문제


//액터 이전엔 문제를 어떻게 해결했을까
//액터는 어떤 문제를 해결할 수 있을까?

/***************************************************************/

//일단 메인스레드가 아닌 다른 스레드(애플이 알아서 정해주는)에서 처리하고
//클래스는 스레드세이프하지 않다. 여러스레드에서 한 클래스에 접근을 하는 경우에 있어서 위험이 발생할 여지가 있다. 어떻게 고쳐야 할까?
//Thread Sanizter를 타겟에서 설정하고 로그를 보면서 Swift Access Warning을 볼 수 있긴 하지만 이걸로 계속 확인해가면서 개발을 해야 할까?

class MyDataManager {
    static let instance = MyDataManager()
    
    private init() { }
    
    var data: [String] = []
    
    //경쟁상황 관련 문제, 스레드세이프 관련 문제를 막는 첫번째 방법
    //클래스 자체를 스레드세이프하게 만든다. 큐를 만들어서 관리를 한다던가 하는 식으로
    private let lock = DispatchQueue(label: "com.myApp.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
}

struct HomeView: View {
    
    let manager = MyDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.red.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            DispatchQueue.global(qos: .background).async {
                manager.getRandomData { title in
                    if let data = title {
                        //UI만 메인스레드에서 바꾸도록
                        DispatchQueue.main.async {
                            self.text = data
                        }
                    }
                }
            }
        }
    }
}

struct BrowseView: View {
    let manager = MyDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            DispatchQueue.global(qos: .default).async {
                manager.getRandomData { title in
                    if let data = title {
                        //UI만 메인스레드에서 바꾸도록
                        DispatchQueue.main.async {
                            self.text = data
                        }
                    }
                }
            }
        }
    }
}

struct ActorsBootCamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorsBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorsBootCamp()
    }
}
