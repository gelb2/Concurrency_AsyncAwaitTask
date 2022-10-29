//
//  SendableBootcamp.swift
//  SwiftConCurrency_Async_Task
//
//  Created by pablo.jee on 2022/10/30.
//

import SwiftUI

//센더블은 뭘까

//클래스가 경쟁조건으로 인해 스레드세이프하지 않음을 생각해보자.
//액터는 스레드세이프한데, 액터 안에 클래스를 던져넣으면 어떻게 될까? 문제가 생길 수 있다. 클래스를 참조하는 넘들이 여럿이 있을 것이니까
//그래서 센더블 프로토콜이 존재하는 것. 센더블 프로토콜은 그 프로토콜을 따르는 타입이 concurrent Code 상에서 안전하게 쓰이도록 만들어진 것

actor CurrentUserManager {
    
    
    func updateDataBase(userInfo: MyClassUserInfo) {
        
    }
    
}

//The Sendable protocol indicates that value of the given type can be safely used in concurrent code.
struct MyUserInfo: Sendable {
    let name: String
}

//Non-final class 'MyClassUserInfo' cannot conform to 'Sendable'; use '@unchecked Sendable'
//클래스가 센더블을 따르면 일단 워닝이 뜬다. final class로 바꾸라고
final class MyClassUserInfo: @unchecked Sendable {
    //Stored property 'name' of 'Sendable'-conforming class 'MyClassUserInfo' is mutable
    //근데 현실적으론 var로 여기저기서 바꾸게끔 해야 클래스를 현실적으로 쓰는 것이다. 어떻게 할까?
    //클래스를 @unchecked Sendable 로 명시하면 된다
    //근데 @unchecked는 정말 위험한 짓중 하나다. 시스템이 sendable인지 체크를 하는 것을 막고 내가 알아서 하겠단 뜻이니까
    //그러므로 @unchecked를 명시했다면 클래스 안에 큐를 하나 두고 그 안에서만 스레드세이프하게 값을 바꾸게끔 하는 추가 처리를 하는게 더 안전하다
    //하지만 @unchecked와 queue를 추가해서 스레드세이프함을 구현하는 것은 그리 완벽한 방법은 아니다.
    //
    var name: String
//    let name: String
    
    let queue = DispatchQueue(label: "com.myQueue")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
    
}

class SendableBootcampViewModel: ObservableObject {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        
        //스트럭트는 값타입이다. 그러므로 스레드세이프하다
        let userInfo = MyClassUserInfo(name: "name")
        
        //sendable 을 따르지 않는 클래스를 파라미터로 넣었어도 에러는 안 난다.
        await manager.updateDataBase(userInfo: userInfo)
    }
    
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                
            }
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
