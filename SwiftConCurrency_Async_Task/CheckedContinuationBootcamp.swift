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
    
}

class CheckedContinuationBootcampViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationBootcampNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
            let data = try await networkManager.getData(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print(error)
        }
    }
}

//async await 에 대응을 하지 않은 서드파티라이브러리랑 async await를 어떻게 써야 할까?
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
            await viewModel.getImage()
        }
    }
}

struct CheckedContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
