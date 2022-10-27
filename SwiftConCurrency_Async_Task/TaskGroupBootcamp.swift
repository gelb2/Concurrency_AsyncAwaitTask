//
//  TaskGroupBootcamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/28.
//

import SwiftUI

class TaskGroupBootcampDataManager {
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/300")
        
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        return [image1, image2, image3, image4]
    }
    
    func fetchIOmagesWithTaskGroup() async throws -> [UIImage] {
        
        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"
        ]
        
        //withThrowningTaskGroup과 withTaskGroup의 차이는 에러 던지기의 여부다
        
        //태스크그룹 안의 차일드태스크 타입을 정해준다. 이미지를 던지는 메소드를 넣을 예정이니 UIImage.self
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            
            var images: [UIImage] = []
            //컴파일러에게 정확한 배열 사이즈를 알려주면 최적화에 도움이 된다
            images.reserveCapacity(urlStrings.count)
            
            for urlString in urlStrings {
                //차일드태스크를 만들어서 그룹에 추가한다
                //차일드태스크는 패런츠태스크의 프라이오리티를 따라간다. 필요시에 프라이오리티를 수정하면 된다
                group.addTask {
                    //루프로 돌린 리퀘스트중 하나 정도는 실패하더라도 나머지 값은 다 리턴을 받는게 좋으므로 옵셔널로 수정
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            //루프가 다 돌아서 group의 갯수만큼 이미지들이 다 만들어지고, 만들어진 이미지들이 다 append되면 return images를 호출
            //group안에 들어간 차일드태스크들은 모두 동시에 concurrent하게 동시에 호출된다
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
           let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupBootcampDataManager()
    
    func getImages() async {
        if let images = try? await manager.fetchIOmagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupBootcamp: View {
    
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("task group")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

struct TaskGroupBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupBootcamp()
    }
}
