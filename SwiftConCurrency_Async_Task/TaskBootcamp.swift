//
//  TaskBootcamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/28.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
//        for x in array {
//            Task.checkCancellation() //태스크가 캔슬되면 에러를 던진다
//        }
        
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            await MainActor.run(body: {
                self.image = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            self.image2 = UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("click me ") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    
    @StateObject private var viewModel = TaskBootcampViewModel()
    //@State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        //onAppear일시 task가 작동할 수 있도록 하는 모디파이어
        //이 모디파이어 안에 들어간 메소드는 task 호출뿐만 아니라. cancel도 onDisappear에서 알아서 호출된다
        //그러나 fetchImage가 매우 긴 기능을 해서 task가 캔슬되기 매우 오래걸리는 상황이라면 메소드 안에서 체크를 해줘야 한다.
        //Task.checkCancellation() //태스크가 캔슬되면 에러를 던진다
        .task {
            await viewModel.fetchImage()
        }
        /*
        .onDisappear {
            fetchImageTask?.cancel()
        }
         */
        /*
        .onAppear {
            fetchImageTask = Task {
                await viewModel.fetchImage()
            }
            
//            Task {
//
//                //이 둘을 동시에 호출하려면 어떻게 해야 할까? Task를 2개 해도 되나...다른 방법도 있다
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage()
////                await viewModel.fetchImage2()
//            }
//
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
            
            //구동되는 스레드가 같더라도 프라이오리티에 따라 끝나는 시간은 다를 수 있다
            /*
            //high와 userIniated는 TaskPriority.rawValue가 25로 같다
            Task(priority: .high) {
                //yield는 현재 태스크를 suspend하고 다음 태스크가 실행될 것을 허락하는 메소드
            
                await Task.yield()
                print("high : \(Thread.current) : \(Task.currentPriority)")
            }
            
            //high와 userIniated는 TaskPriority.rawValue가 25로 같다
            Task(priority: .userInitiated) {
                print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
            }
            
            //TaskPriority.rawValue가 21
            Task(priority: .medium) {
                print("medium : \(Thread.current) : \(Task.currentPriority)")
            }
            
            //low와 utility는 TaskPriority.rawValue가 17로 같다
            Task(priority: .low) {
                print("low : \(Thread.current) : \(Task.currentPriority)")
            }
            
            //low와 utility는 TaskPriority.rawValue가 17로 같다
            Task(priority: .utility) {
                print("utility : \(Thread.current) : \(Task.currentPriority)")
            }
            
            //TaskPriority.rawValue가 9
            Task(priority: .background) {
                
                print("background : \(Thread.current) : \(Task.currentPriority)")
            }
            */
            
//            Task(priority: .low) {
//                print("low : \(Thread.current) : \(Task.currentPriority)")
//                //차일드태스크는 패런츠태스크의 프라이오리티를 따라간다
//                //차일드태스크를 detached로 패런츠태스크에서 때네면 프라이오리티가 달라진다
//                //하지만 애플은 정말 필요한 경우가 아니라면, 가능하면 detached를 하지 말것을 권장한다.
//                //그래서 태스크그룹을 고려해야 한다
//                Task.detached {
//                    print("low : \(Thread.current) : \(Task.currentPriority)")
//                }
//            }
        }
        */
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcamp()
    }
}
