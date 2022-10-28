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

extension StructClassActorBootcamp {
    private func runTest() {
        print("test start")
//        structTest1()
//        printDivider()
//        classTest()
//        structTest2()
        classTest2()
    }
    
    private func printDivider() {
        print("""
        ---------------------------
        """)
    }
    
    private func structTest1() {
        print("structTest1")
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
    
    private func classTest() {
        print("classTest1")
        let objectA = MyClass(title: "starting title")
        print("object a ", objectA.title)
        
        
        print("pass the reference of objecta  to objectb")
        //클래스는 let으로 선언되어 있어도 let 인스턴스의 내부 변수를 변경할 수 있다
        //objectB와 objectA는 같은 인스턴스를 가리키고 있다. 참조를 전달했으므로
        let objectB = objectA
        print("object b ", objectB.title)
        
        objectB.title = "second title"
        print("object b title changed")
        
        //a와 b의 타이틀 모두 바뀐다.
        print("object a ", objectA.title)
        print("object b ", objectB.title)
    }
}

struct MyStruct {
    var title: String
}

//immutable struct
struct CustomStruct {
    let title: String
    
    //struct 안의 변수를 바꾼다는 것은 struct 오브젝트 전체를 새로 만든 다는 것과 유사한 의미이다.
    func updateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}

//왜 이렇게 muatting func를 할까?
//struct가 업데이트 되는 것을 제약하고 싶을 때가 있을 것이다. "변화를 꼭 주고 싶을때"는 꼭 mutating func를 호출해서 바꾸도록, private var인 변수를 바꾸고 싶을때 mutating func를 호출하도록 유도하는 것이라고 이해하면 된다
struct MutatingStruct {
    private (set) var title: String
    
    //struct 안의 변수를 바꾼다는 것은 struct 오브젝트 전체를 새로 만든 다는 것과 유사한 의미이다.
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorBootcamp {
    
    private func structTest2() {
        var struct1 = MyStruct(title: "title1")
        print("struct1 :\(struct1.title)")
        struct1.title = "title2"
        print("struct1 :\(struct1.title)")
        
        var struct2 = CustomStruct(title: "title2")
        print("struct2 :\(struct2.title)")
        struct2 = CustomStruct(title: "title2")
        print("struct2 :\(struct2.title)")
        
        var struct3 = CustomStruct(title: "title1")
        print("struct3 :\(struct3.title)")
        struct3 = struct3.updateTitle(newTitle: "title2")
        print("struct3 :\(struct3.title)")
        
        var struct4 = MutatingStruct(title: "title1")
        print("struct4 :\(struct4.title)")
        struct4.updateTitle(newTitle: "title2")
        print("struct4 :\(struct4.title)")
    }
    
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    //mutating is not valid for instance method in class
    //mutating을 붙일 필요가 없는 이유는 클래스는 스트럭트와 달리 내부 변수를 바꾼다고 인스턴스 자체를 확 바꿔버리는 식으로 동작하지 않기 때문임
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorBootcamp {
    
    private func classTest2() {
        print("class test2")
        
        //보통 레퍼런스를 전달하는 것이 스트럭스에서 값을 복사해서 새 인스턴스 변수에 할당해주는 것보다 느리다
        let class1 = MyClass(title: "title1")
        print("class 1 \(class1.title)")
        //스트럭트랑 달리, 내부변수를 변경해도 인스턴스 자체가 완전히 바뀌는 것은 아니다
        class1.title = "title2"
        print("class 1 \(class1.title)")
        
        let class2 = MyClass(title: "title1")
        print("class 2 \(class2.title)")
        class2.updateTitle(newTitle: "title2")
        print("class 2 \(class2.title)")
    }
}

//밸류타입의 예: 스트럭트, 이넘, 튜플, 스트링, 배열, 셋 등 자료형
//밸류 타입을 할당하면 새로운 복사본이 만들어진다. CopyOnWrite 메커니즘은 특정한 타입(컬렉션, 배열, 딕셔너리, 셋 같은)에 사용된다
//많은 개발자들, 그리고 애플은 레퍼런스를 여러곳으로 전달하는 것 보다 카피하는 밸류타입의 속성이 더 안전하고 최적화된 방식이라고 생각한다.

//레퍼런스타입의 예: 클래스, 함수
//레퍼런스 타입을 할당하면 새 인스턴스에 레퍼런스가 전달된다
//ARC 메커니즘이 사용된다
//
//밸류타입과 레퍼런스타입은 메모리영역, 즉 스텍과 힙 영역을 사용하는데 있어서 큰 차이가 있으므로 그 부분을 잘 보도록 해라

//weak self의 기준은 뭘까?
/*
 arc는 레퍼런스카운팅을 기준으로 객체를 없앨지 말지 체크한다
 클래스 내부에 urlSession 관련 코드가 있고, 코드의 컴플리션핸들러 같은걸 쓸 때 weak self를 안 쓰면 어떻게 될까
 이스케이핑 클로저는 datatask 함수 실행을 하자마자 바로 실행되지 않는다, 리스폰스를 기다리기 때문이다. 즉 데이터테스크 함수와 클로저의 실행 사이엔 갭이 있다.
 그리고 클래스는 힙 영역에 있을 것이다.
 근데 이때 유저가 백버튼을 눌러서 뒤로가기를 하고 또 다른 화면에 진입하고 하면 urlSession 관련 코드를 가진 클래스는 알아서 잘 사라졌다가 다시 초기화되고 해야 할 것이다.
 이런 경우, weak self를 안 쓰고 strong self 상태로 한다면 시스템은 클래스를 메모리에서 해제하질 못할 것이다. strong self 상태로 하면 레퍼런스카운트가 1 올라간 상태일 것이기 때문이다.
 weak self는 레퍼런스카운트를 올리지 않으면서 self, 즉 클래스 본인을 옵셔널과 비슷한 상태로 만들어 놓겠다는 의미와 유사하다. 즉 self?.handleResponse() 라고 되어 있다면, self가 메모리에 있으면 함수를 실행하고, 어떤 이유로 인해 메모리에서 해제되었다면 그냥 안하겠다는 의미다
 클로저의 관점으로 다시 생각해보자. urlSession.dataTask를 호출할 때 클래스 즉 self는 분명히 메모리 힙 영역에 존재할 것이다. 그러나 dataTAsk의 클로저가 호출될때, 즉 리스폰스가 날아왔을때도 힙 영역에 있을 거라는 보장을 할 수 있을까? 그건 상황에 따라 다를 것이다. 만약 "어떠한 상황으로 인해 self가 반드시 클로저가 호출될 때 살아있어야 한다면" strong self를 써야할 상황도 있따는 것을 생각해놔야 한다.
 */
