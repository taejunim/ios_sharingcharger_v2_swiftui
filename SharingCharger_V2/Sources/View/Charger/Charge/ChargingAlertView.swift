//
//  ChargingAlertView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/16.
//

import SwiftUI

//MARK: - 충전 진행 알림창
struct ChargingAlert: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("충전하기")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text(chargerMap.chargerName)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 5) {
                            HStack(spacing: 2) {
                                Text("충전 시작일시 :")
                                    .fontWeight(.bold)
                                
                                Text("\(chargerSearch.textStartDay) \(chargerSearch.textStartTime)")
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 2) {
                                Text("충전 종료일시 :")
                                    .fontWeight(.bold)
                                
                                Text("\(chargerSearch.textEndDay) \(chargerSearch.textEndTime)")
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("총 \(chargerSearch.textChargingTime) 충전")
                        .fontWeight(.bold)
                    
                    Text("충전을 진행하시겠습니까?")
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                reservation.isShowChargingAlert = false
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        Button(
                            action: {
                                //현재 일시 호출 후 즉시 충전 예약 진행
                                chargerSearch.getCurrentDate() { (currentDate) in
                                    let calcDate: Date = Calendar.current.date(byAdding: .second, value: chargerSearch.selectChargingTime, to: currentDate)!    //충전 종료 일시 계산

                                    chargerSearch.currentDate = currentDate //현재 일시
                                    chargerSearch.chargingStartDate = currentDate   //충전 시작일시
                                    chargerSearch.chargingEndDate = calcDate //충전 종료일시

                                    //즉시 충전 예약 실행
                                    reservation.reservation(
                                        chargerId: chargerMap.selectChargerId,  //충전기 ID
                                        chargeReservationType: "Instant",   //충전 예약 유형
                                        chargerSearch.chargingStartDate!,   //충전 시작일시
                                        chargerSearch.chargingEndDate!  //충전 종료일시
                                    ) { (result, reservation) in
                                        
                                        //즉시 충전 예약 성공
                                        if result == "success" {
                                            self.reservation.userIdNo = String(reservation!.userId) //예약 사용자 ID 번호
                                            self.reservation.reservationId = String(reservation!.id)    //예약 번호
                                            self.reservation.reservedChargerId = String(reservation!.chargerId) //예약 충전기 번호
                                            self.reservation.reservedchargerBLENumber = reservation!.bleNumber! //예약 충전기 BLE 번호
                                            self.reservation.reservationStartDate = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'".toDateFormatter(formatString: reservation!.startDate!)
                                            self.reservation.reservationEndDate = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'".toDateFormatter(formatString: reservation!.endDate!)
                                            
                                            //충전기 재 조회 후, 예약한 충전기로 이동
                                            chargerMap.moveToReservedCharger(chargerId: self.reservation.reservedChargerId, latitude: chargerMap.latitude, longitude: chargerMap.longitude)
                                            
                                            self.reservation.viewUtil.showToast(isShow: true, message: "정상적으로 즉시 충전 예약이 완료되었습니다.\n충전 진행 화면으로 이동합니다.")
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                withAnimation {
                                                    chargerMap.isShowChargingView = true  //충전 화면 활성화
                                                }
                                            }
                                        }
                                        //즉시 충전 예약 실패
                                        else if result == "fail" {
                                            self.reservation.viewUtil.showToast(isShow: true, message: "즉시 충전을 위한 예약이 실패하였습니다.\n자세한 사항은 고객 센터에 문의 바랍니다.")
                                        }
                                        //즉시 충전 예약 오류
                                        else {
                                            self.reservation.viewUtil.showToast(isShow: true, message: "server.error".message())
                                        }
                                        
                                        self.reservation.isShowChargingAlert = false  //충전하기 알림창 비활성화
                                    }
                                }
                            },
                            label: {
                                Text("충전")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#3498DB"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.2, height: 250)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - 충전기 예약 확인 알림창
struct ReservationConfirmAlert: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("예약하기")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text(chargerMap.chargerName)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 5) {
                            HStack(spacing: 2) {
                                Text("예약 시작일시 :")
                                    .fontWeight(.bold)
                                
                                Text("MM/dd (E) HH:mm".dateFormatter(formatDate: chargerSearch.chargingStartDate!))
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 2) {
                                Text("예약 종료일시 :")
                                    .fontWeight(.bold)
                                
                                Text("MM/dd (E) HH:mm".dateFormatter(formatDate: chargerSearch.chargingEndDate!))
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("총 \(chargerSearch.textChargingTime) 예약")
                        .fontWeight(.bold)
                    
                    Text("예약을 진행하시겠습니까?")
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                reservation.isShowConfirmAlert = false
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        //예약 버튼
                        Button(
                            action: {
                                reservation.reservation(
                                    chargerId: chargerMap.selectChargerId,  //충전기 ID
                                    chargeReservationType: "Scheduled", //충전 예약 유형
                                    chargerSearch.chargingStartDate!,   //충전 시작일시
                                    chargerSearch.chargingEndDate!  //충전 종료일시
                                ) { (result, reservation) in
                                    self.reservation.isShowConfirmAlert = false

                                    //충전기 예약 성공
                                    if result == "success" {
                                        self.reservation.viewUtil.showToast(isShow: true, message: "정상적으로 예약이 완료되었습니다.")

                                        //충전기 재 조회 후, 예약한 충전기로 이동
                                        chargerMap.moveToReservedCharger(chargerId: String(reservation!.chargerId), latitude: chargerMap.latitude, longitude: chargerMap.longitude)
                                        
                                        withAnimation {
                                            self.presentationMode.wrappedValue.dismiss()    //예약 진행 화면 닫기
                                        }
                                    }
                                    //충전기 예약 실패
                                    else if result == "fail" {
                                        self.reservation.viewUtil.showToast(isShow: true, message: "예약이 실패하였습니다.\n자세한 사항은 고객 센터에 문의 바랍니다.")
                                    }
                                    //충전기 예약 오류
                                    else {
                                        self.reservation.viewUtil.showToast(isShow: true, message: "server.error".message())
                                    }
                                }
                            },
                            label: {
                                Text("예약")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#3498DB"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.2, height: 250)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - 예약 취소 알림창
struct CancelReservationAlert: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("예약 취소")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    Text("해당 충전기 예약 건을 취소하시겠습니까?")
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                reservation.isShowCancelAlert = false //예약 취소 알림창 비활성화
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        //예약 취소 확인 버튼
                        Button(
                            action: {
                                let chargeReservationType = reservation.chargeReservationType   //충전 예약 유형 - Instant: 즉시 충전, Scheduled:예약 충전
                                
                                //즉시 충전 예약 취소
                                if chargeReservationType == "Instant" {
                                    //즉시 충전 예약 취소 실행
                                    reservation.cancelInstantCharge() { (result) in
                                        reservation.isShowCancelAlert = false //예약 취소 알림창 비활성화
                                        
                                        //예약 취소 성공
                                        if result == "success" {
                                            reservation.viewUtil.showToast(isShow: true, message: "해당 예약 건이 정상적으로 취소되었습니다.")
                                            chargerMap.currentLocation(chargerMap.currentDate, chargerMap.currentDate)  //현재 위치의 충전기 조회 갱신
                                        }
                                        //예약 취소 실패
                                        else if result == "fail" {
                                            reservation.viewUtil.showToast(isShow: true, message: "해당 예약 건의 취소가 실패하였습니다.\n즉시 충전 건은 10분 이내에만 취소 가능하며, 자세한 사항은 고객 센터에 문의 바랍니다.")
                                        }
                                        //예약 취소 오류
                                        else {
                                            reservation.viewUtil.showToast(isShow: true, message: "server.error".message())
                                        }
                                    }
                                }
                                //충전기 예약 충전 취소
                                else if chargeReservationType == "Scheduled" {
                                    //충전기 예약 취소 실행
                                    reservation.cancelReservation() { (result) in
                                        reservation.isShowCancelAlert = false //예약 취소 알림창 비활성화
                                        
                                        //예약 취소 성공
                                        if result == "success" {
                                            reservation.viewUtil.showToast(isShow: true, message: "해당 예약 건이 정상적으로 취소되었습니다.")
                                            chargerMap.currentLocation(chargerMap.currentDate, chargerMap.currentDate)  //현재 위치의 충전기 조회 갱신
                                        }
                                        //예약 취소 실패
                                        else if result == "fail" {
                                            reservation.viewUtil.showToast(isShow: true, message: "해당 예약 건의 취소가 실패하였습니다.\n자세한 사항은 고객 센터에 문의 바랍니다.")
                                        }
                                        //예약 취소 오류
                                        else {
                                            reservation.viewUtil.showToast(isShow: true, message: "server.error".message())
                                        }
                                    }
                                }
                            },
                            label: {
                                Text("확인")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#3498DB"))
                                    .cornerRadius(5.0)
                                    .shadow(color: Color.gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.2, height: 200)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}


//MARK: - 충전 결과 알림창
struct ChargingResultAlert: View {
    @ObservedObject var charging: ChargingViewModel
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("충전 종료")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        ChargingPointDetail(charging: charging)
                        
                        ChargingTimeResult(charging: charging)
                    }
                    .padding()
                    
                    Spacer()
                    
                    //충전 결과 알림 확인 버튼
                    Button(
                        action: {
                            withAnimation {
                                charging.isShowChargingResult = false
                                chargerMap.isShowChargingView = false
                            }
                            
                            reservation.getUserReservation()    //사용자의 예약 정보 재호출
                            
                            //충전기 목록 재조회
                            charging.getCurrentDate() { (currentDate) in
                                chargerMap.getChargerList(
                                    zoomLevel: 0,   //Zoom Level
                                    latitude: chargerMap.latitude,  //위도
                                    longitude: chargerMap.longitude,    //경도
                                    searchStartDate: currentDate,  //조회 시작일시
                                    searchEndDate: currentDate   //조회 종료일시
                                ) { _ in }
                            }
                        },
                        label: {
                            Text("확인")
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, minHeight: 35)
                                .background(Color("#3498DB"))
                                .cornerRadius(5.0)
                                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        }
                    )
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.1, height: 350)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - 충전 포인트 내역
struct ChargingPointDetail: View {
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("포인트 내역")
                    .fontWeight(.bold)
                    .font(.title3)
                
                Spacer()
            }
            
            Dividerline()
            
            VStack(spacing: 5) {
                HStack {
                    Text("예약 차감 포인트")
                    
                    Spacer()
                    
                    Text("-" + String(charging.prepaidPoint).pointFormatter())
                        .foregroundColor(Color("#C0392B"))
                }
                
                HStack {
                    Text("예상 환불 포인트")
                    
                    Spacer()
                    
                    Text("+" + String(charging.refundPoint).pointFormatter())
                        .foregroundColor(Color("#3498DB"))
                }
                
                Dividerline()
                
                HStack {
                    Text("실제 차감 포인트")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("-" + String(charging.deductionPoint).pointFormatter())
                        .foregroundColor(Color("#C0392B"))
                        .fontWeight(.semibold)
                }
                .padding(.top, 5)
            }
            .padding(5)
            .padding(.top, 5)
            
            Dividerline()
        }
    }
}

//MARK: - 충전 시간 결과
struct ChargingTimeResult: View {
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("충전 시간 정보")
                    .fontWeight(.bold)
                    .font(.title3)
                
                Spacer()
            }
            
            Dividerline()
            
            VStack(spacing: 5) {
                VStack(spacing: 5) {
                    HStack {
                        Text("예약 시작 시간")
                        
                        Spacer()
                        
                        Text("yyyy-MM-dd HH:mm".dateFormatter(formatDate: charging.reservationStartDate!))
                    }
                    
                    HStack {
                        Text("예약 종료 시간")
                        
                        Spacer()
                        
                        Text("yyyy-MM-dd HH:mm".dateFormatter(formatDate: charging.reservationEndDate!))
                    }
                }
                
                Spacer().frame(height: 1)
                
                VStack(spacing: 5) {
                    HStack {
                        Text("충전 시작 시간")
                        
                        Spacer()
                        
                        Text("yyyy-MM-dd HH:mm".dateFormatter(formatDate: charging.chargingStartDate))
                    }
                    
                    HStack {
                        Text("충전 종료 시간")
                        
                        Spacer()
                        
                        Text("yyyy-MM-dd HH:mm".dateFormatter(formatDate: charging.chargingEndDate))
                    }
                }
                
                Dividerline()
                
                HStack {
                    Text("실제 충전 시간")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(charging.totalChargingTime)
                        .fontWeight(.semibold)
                }
                .padding(.top, 5)
            }
            .padding(5)
            .padding(.top, 5)
            
            Dividerline()
        }
    }
}

struct ChargingAlertView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChargingResultAlert(charging: ChargingViewModel(), chargerMap: ChargerMapViewModel(), reservation: ReservationViewModel())
    }
}
