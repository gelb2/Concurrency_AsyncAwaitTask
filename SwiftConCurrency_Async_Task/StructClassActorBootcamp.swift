//
//  StructClassActorBootcamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by sokol on 2022/10/28.
//

import SwiftUI


//스트럭트 클래스 액터 얘들의 차이는 뭘까
struct StructClassActorBootcamp: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                runTest()
            }
    }
}

struct StructClassActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActorBootcamp()
    }
}

struct MyStruct {
    var title: String
}

extension StructClassActorBootcamp {
    private func runTest() {
        print("test start")
        structTest1()
    }
    
    private func structTest1() {
        let objectA = MyStruct(title: "starting title")
        print("object a ", objectA.title)
        
        //struct 안의 변수를 바꾼다는 것은 struct 전체를 새로 만든 다는 것과 유사한 의미이다
        //그래서 objectB의 내부변수를 바꾸면 var objectB로 바꾸라고 에러가 나는 것이다
        print("pass the values of objecta  to objectb")
        var objectB = objectA
        print("object b ", objectB.title)
        
        //object는 스트럭트이므로 b의 타이틀을 바꿔도 a의 타이틀은 바뀌지 않는다.
        objectB.title = "second title"
        print("object b title changed")
        
        print("object a ", objectA.title)
        print("object b ", objectB.title)
    }
}
