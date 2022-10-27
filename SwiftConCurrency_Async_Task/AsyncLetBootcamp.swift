//
//  AsyncLetBootcamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/28.
//

import SwiftUI

struct AsyncLetBootcamp: View {
    
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("async let title")
            .onAppear {
                
                //태스크 안에 있는 fetchImage() 들은 serial하게 불린다...await로 기다리게 하니까...
                //어떻게 concurrent 하게 할까?
                Task {
                    do {
                        
                        //일단 async let 으로 선언해서 메소드의 리턴값을 하나하나 await 할 필요가 없어짐
//                        async let fetchImage1 = fetchImage()
//                        async let fetchTitle1 = fetchTitle()
                        
                        //이미지, 스트링 처럼 서로 다른 타입을 리턴하는 async 메소드여도 한번에 await 를 걸 수 있다
//                        let (image, title) = await (try fetchImage1, fetchTitle1)
                        
//                        async let fetchImage2 = fetchImage()
//                        async let fetchImage3 = fetchImage()
//                        async let fetchImage4 = fetchImage()
//                        //위의 async let 변수들이 다 만들어질때 한번에 await를 건다
//                        //try 한 모든 변수들이 다 성공적으로 set되면 let 변수가 만들어진다. 근데 이러면 하나라도 실패하면 아예 let 변수가 안 만들어지니 try? 로 시도하는게 좋다
//                        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
//                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        
//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    func fetchTitle() async -> String {
        return "new title"
    }
    
    func fetchImage() async throws -> UIImage {
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

struct AsyncLetBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetBootcamp()
    }
}
