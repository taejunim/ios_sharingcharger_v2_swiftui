//
//  AddressSearchModal.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/10/08.
//

import SwiftUI

struct AddressSearchModal: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var addressSearch = AddressSearchViewModel()
    
    var body: some View {
        VStack(spacing: 1) {
            AddressSearchWordEntryField(addressSearch: addressSearch)   //주소 검색어 입력 영역
            
            CenterLocationSelectButton(addressSearch: addressSearch)    //중심위치 선택 버튼
            
            VerticalDividerline()   //구분선 - Vertical
            
            AddressSearchList(addressSearch: addressSearch, chargerMap: chargerMap) //주소검색 목록
            
            Spacer()
        }
        .onAppear {
            addressSearch.getLoacation()    //현재 사용자 위치 호출
            
            addressSearch.mapCenterLatitude = chargerMap.latitude   //현재 지도중심 위도
            addressSearch.mapCenterLongitude = chargerMap.longitude //현재 지도중심 경도
        }
    }
}

//MARK: - 주소 검색어 입력 영역
struct AddressSearchWordEntryField: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var addressSearch: AddressSearchViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            BackButton()
                .padding(.leading)
            
            TextField(
                "장소・주소・전화번호 검색",
                text: $addressSearch.searchWord,
                onEditingChanged: { _ in
                },
                onCommit: {
                    addressSearch.isSearch = true
                    addressSearch.getAddressList()
                }
            )
                
            Spacer()
            
            Button(
                action: {
                    addressSearch.searchWord = ""
                    addressSearch.place.removeAll()
                    addressSearch.places.removeAll()
                },
                label: {
                    HStack {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                }
            )
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(Color.white)
        .cornerRadius(5.0)
        .shadow(color: .gray, radius: 2, x: 1.5, y: 1.5)
        .padding()
    }
}

//MARK: - 중심위치 선택 버튼
struct CenterLocationSelectButton: View {
    @ObservedObject var addressSearch: AddressSearchViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            //내위치중심 버튼
            Button(
                action: {
                    addressSearch.selectCenterLocation = "user"
                    addressSearch.getLoacation()
                },
                label: {
                    HStack(spacing: 1) {
                        Image(systemName: "checkmark")
                            .font(Font.system(size: 12, weight: .semibold))
                            .foregroundColor(addressSearch.selectCenterLocation == "user" ? Color("#3498DB") : Color.gray)
                        
                        Text("내위치중심")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(addressSearch.selectCenterLocation == "user" ? Color.black : Color.gray)
                        
                        Spacer()
                    }
                    .frame(width: 90)
                }
            )
            
            //지도중심 버튼
            Button(
                action: {
                    addressSearch.selectCenterLocation = "map"
                },
                label: {
                    HStack(spacing: 1) {
                        Image(systemName: "checkmark")
                            .font(Font.system(size: 12, weight: .semibold))
                            .foregroundColor(addressSearch.selectCenterLocation == "map" ? Color("#3498DB") : Color.gray)
                        
                        Text("지도중심")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(addressSearch.selectCenterLocation == "map" ? Color.black : Color.gray)
                        
                        Spacer()
                    }
                    .frame(width: 90)
                }
            )
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

//MARK: - 주소검색 목록
struct AddressSearchList: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var addressSearch: AddressSearchViewModel
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        ScrollView {
            //검색 결과가 없는 경우
            if addressSearch.totalCount == 0 {
                VStack(spacing: 5) {
                    //검색 여부에 따라 안내 문구 변경
                    if !addressSearch.isSearch {
                        //검색어가 공백인 경우
                        if addressSearch.searchWord.isEmpty {
                            Image(systemName: "exclamationmark.circle")
                                .font(.largeTitle)
                                .foregroundColor(Color("#BDBDBD"))
                            
                            Text("장소・주소・전화번호를 검색하세요.")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                    }
                    else {
                        Image(systemName: "exclamationmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(Color("#BDBDBD"))
                        
                        Text("검색 결과가 없습니다.")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                }
                .padding()
            }
            //검색 결과가 있는 경우
            else {
                LazyVStack(alignment: .leading) {
                    let places = addressSearch.places
                    
                    ForEach(places, id:\.self) { (place) in
                        Button(
                            action: {
                                self.presentationMode.wrappedValue.dismiss()    //화면 닫기

                                let latitude = Double(place["latitude"]!)!  //선택한 장소의 위도
                                let longitude = Double(place["longitude"]!)!    //선택한 장소의 경도

                                //선택한 위치의 지도 중심으로 이동
                                chargerMap.mapView.setMapCenter(
                                    MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude)),
                                    animated: true
                                )

                                chargerMap.mapView.setZoomLevel(MTMapZoomLevel(0), animated: true)   //Zoom Level 설정

                                //선택한 위치의 충전기 목록 조회
                                chargerMap.getChargerList(
                                    zoomLevel: 0,
                                    latitude: latitude, longitude: longitude,
                                    searchStartDate: chargerMap.searchStartDate!, searchEndDate: chargerMap.searchEndDate!
                                ) { _ in }
                            },
                            label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 1) {
                                        //카테고리가 전기자동차 충전소인 경우 충전기 마커 이미지 표시
                                        if place["category"]!.contains("전기자동차 충전소") {
                                            //충전기 마커 이미지
                                            Image("Charge-Position")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                        }

                                        //주소 장소명
                                        Text(place["placeName"]!)
                                            .font(.callout)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.black)

                                        Spacer().frame(width: 4)

                                        //카테고리
                                        Text(place["category"]!)
                                            .font(.caption)
                                            .foregroundColor(Color.gray)
                                    }

                                    HStack(spacing: 5) {
                                        //검색 위치와의 거리
                                        Text(place["distance"]!)
                                            .font(.footnote)
                                            .foregroundColor(Color.black)

                                        Text("|")
                                            .font(.footnote)
                                            .foregroundColor(Color.gray)

                                        //도로명 주소가 있는 경우 도로명 주소 노출
                                        if place["roadAddress"]! != "" {
                                            //도로명 주소
                                            Text(place["roadAddress"]!)
                                                .font(.footnote)
                                                .foregroundColor(Color("#5E5E5E"))
                                        }
                                        //도로명 주소가 없는 경우 지번 주소 노출
                                        else {
                                            HStack(spacing: 5) {
                                                //지번 표시 라벨
                                                Text("지번")
                                                    .font(.caption2)
                                                    .foregroundColor(Color.gray)
                                                    .padding(.horizontal, 5)
                                                    .padding(.vertical, 1)
                                                    .border(Color.gray, width: 0.5)

                                                //지번 주소
                                                Text(place["address"]!)
                                                    .font(.footnote)
                                                    .foregroundColor(Color.gray)
                                            }
                                        }
                                    }

                                    //지번 주소가 있는 경우 노출
                                    if place["address"]! != "" {
                                        //도로명 주소가 있는 경우에만 노출, 도로명 주소가 없는 경우 도로명 주소 위치에 지번 주소 노출
                                        if place["roadAddress"]! != "" {
                                            HStack(spacing: 5) {
                                                //지번 표시 라벨
                                                Text("지번")
                                                    .font(.caption2)
                                                    .foregroundColor(Color.gray)
                                                    .padding(.horizontal, 5)
                                                    .padding(.vertical, 1)
                                                    .border(Color.gray, width: 0.5)

                                                //지번 주소
                                                Text(place["address"]!)
                                                    .font(.footnote)
                                                    .foregroundColor(Color.gray)
                                            }
                                        }
                                    }

                                    if place["phone"]! != "" {
                                        //전화 번호
                                        Text(place["phone"]!)
                                            .font(.footnote)
                                            .foregroundColor(Color("#3498DB"))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        )
                        .onAppear {
                            //검색 결과가 마지막 페이지가 아닌 경우 스크롤 시 다음 검색 결과 호출
                            if !addressSearch.isLastPage {
                                //스크롤의 마지막 항목인 경우에만 실행
                                if places.last == place {
                                    addressSearch.page = addressSearch.page + 1
                                    
                                    addressSearch.addNextAddressList()  //다음 주소 목록 추가
                                }
                            }
                        }
                        
                        Dividerline()
                    }
                }
            }
        }
    }
}

struct AddressSearchModal_Previews: PreviewProvider {
    static var previews: some View {
        AddressSearchModal(chargerMap: ChargerMapViewModel())
    }
}
