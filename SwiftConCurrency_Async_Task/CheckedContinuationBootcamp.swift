//
//  CheckedContinuationBootcamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/28.
//

import SwiftUI

class CheckedContinuationBootcampNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
           let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch {
            throw error
        }
    }
    
    //async await 에 대응을 하지 않은 서드파티라이브러리랑 async await를 어떻게 써야 할까?
    //contiuation, withCheckedThrowingContinuation
    //아주 간단히 생각하고 싶다면 escaping 클로저를 withCheckedThrowingContinuation을 이용해 async await로 변화시키는 거라고 이해하면 된다
    func getData2(url: URL) async throws -> Data {
        
        //태스크를 잠시 멈추고, withCheckedThrowingContinuation {} 블록을 호출한다. 즉 URLSession.shared 코드를 호출한다.
        //continuation.resume(returning: data) 에서 resume은 콜백이 날아오면 task를 resume 하겠다는 뜻이다
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    //꼭 한번은 contuniton.resume이 호출되어야 한다. 가이드에 그렇게 나와있다. 안 부르는 것도 안되고 2번 이상 부르는 것도 안된다
                    continuation.resume(returning: data)
                } else if let error = error {
                    //꼭 한번은 contuniton.resume이 호출되어야 한다. 가이드에 그렇게 나와있다. 안 부르는 것도 안되고 2번 이상 부르는 것도 안된다
                    //if let data = data가 안된다면, 즉 data가 없다면 반드시 에러를 던져야 한다.
                    //그렇지 않으면 Task가 계속 suspended 상태로 되고, 결국 버그, 앱이 죽거나 할 것이다
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabase() async -> UIImage {
        return await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class CheckedContinuationBootcampViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationBootcampNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print(error)
        }
    }
    
    func getHeartImage() async {
        let image = await networkManager.getHeartImageFromDatabase()
        self.image = image
    }
}

struct CheckedContinuationBootcamp: View {
    
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

struct CheckedContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
