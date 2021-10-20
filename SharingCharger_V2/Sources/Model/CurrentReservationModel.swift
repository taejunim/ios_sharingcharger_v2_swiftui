//
//  CurrentReservationModel.swift
//  SharingCharger_V2
//
//  Created by tjlim on 2021/10/12.
//

//MARK: - 충전기의 현재 예약 시간 정보 (이용 가능 시간 라벨 계산 용도)
class CurrentReservationModel: NSObject {
    var startDate: String?  //예약 시작일시
    var endDate: String?    //예약 종료일시
}
