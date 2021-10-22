//
//  IdentificationView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/24.
//

import SwiftUI

//MARK: - 회원 증명서
struct IdentificationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var identification = IdentificationViewModel()
    
    var body: some View {
        VStack {
            IdentificationContent(identification: identification)
            //IdentificationContent2(identification: identification)
        }
        .navigationBarTitle(Text("회원 증명서"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        .onAppear {
            identification.getUserDID()
        }
    }
}

//MARK: - 회원 증명서 내용
struct IdentificationContent: View {
    @ObservedObject var identification: IdentificationViewModel
    
    //배경 그라데이션 효과 설정
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color("#006AC5").opacity(1),
                    Color("#006AC5").opacity(0.5)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .shadow(color: .black, radius: 4, x: 2, y: 2)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(gradient)
                    
                    VStack {
                        //상단 제목
                        HStack {
                            //APP 아이콘 이미지
                            ZStack {
                                Image("Label-AppIcon")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .frame(width: 55, height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            
                            //회원 증명서 제목
                            Text("회원 증명서")
                                .font(.title)
                                .fontWeight(.bold)
                              
                            Spacer()
                        }
                        
                        Spacer()
                        
                        //회원 정보
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 5) {
                                //사용자 명
                                Text(identification.userName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                //사용자 아이디(이메일)
                                Text(identification.userId)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                        
                        //DID 발급 정보
                        VStack(spacing: 5) {
                            VStack {
                                //DID
                                HStack {
                                    Text("발급 DID")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Text(identification.did)
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            VStack {
                                //발급 일자
                                HStack {
                                    Text("발급 일자")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Text(identification.issueDate)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                    .padding()
                    .foregroundColor(Color.white)
                }
                .frame(width: geometry.size.width * 0.75, height: geometry.size.height * 0.68)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct IdentificationContent2: View {
    @ObservedObject var identification: IdentificationViewModel
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color("#006AC5").opacity(1),
                    Color("#006AC5").opacity(0.5)
                ]
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .shadow(color: .black, radius: 4, x: 2, y: 2)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(gradient)
                    
                    VStack {
                        HStack {
                            Image("Label-AppIcon")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .cornerRadius(5)
                            
                            Text("회원 증명서")
                                .font(.title2)
                                .fontWeight(.bold)
                              
                            Spacer()
                        }
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 5) {
                                Text(UserDefaults.standard.string(forKey: "userName") ?? "홍길동")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text(UserDefaults.standard.string(forKey: "userId") ?? "example@example.com")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 5) {
                            HStack {
                                Text("회원 ID")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Text("000-000-0000")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("발급일자")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Text("2021.10.21")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding()
                    .foregroundColor(Color.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 250)
                .padding()
                .padding(.vertical, 10)
                
                Rectangle()
                    .cornerRadius(15, corners: .topLeft)
                    .cornerRadius(15, corners: .topRight)
                    .foregroundColor(Color.white)
                    .shadow(color: .black, radius: 2, x: 1.5, y: 1.5)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    //.edgesIgnoringSafeArea(.bottom)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct IdentificationView_Previews: PreviewProvider {
    static var previews: some View {
        IdentificationView()
    }
}
