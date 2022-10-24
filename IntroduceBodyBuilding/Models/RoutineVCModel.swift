//
//  CellModel.swift
//  BodyBuildingProgram
//
//  Created by 윤형석 on 2022/08/16.
//

import Foundation

struct RoutineVCModel: Codable {
        
    var documents: [Fields] = [] //observable로 보내줄 파싱 데이터

    struct Fields: Codable, Equatable{
        var title: String = ""
        var week: String = ""
        var recommend: String = ""
        var division: String = ""
        var weekCount: String = ""
    }
    
    struct StringValue: Codable { //firestore api 형식에 맞게 key name set
        let value: String
        
        init(value: String) {
            self.value = value
        }
        
        private enum CodingKeys: String, CodingKey {
            case value = "stringValue"
        }
    }
    
    enum RootKey: String, CodingKey {  // nestedContainer로 접근하기 위해
        case documents
    }
    enum DocumentKeys: String, CodingKey{
        case fields
    }
    enum FieldKeys: String, CodingKey{
        case title, week, recommend, division, weekCount
    }
}

extension RoutineVCModel {
    init(from decoder: Decoder) throws {
        
        let rootKey = try decoder.container(keyedBy: RootKey.self) //document의 value값에 접근 위해
        var rootKeyArray = try rootKey.nestedUnkeyedContainer(forKey: .documents) //value값의 배열 형태에 접근하기 위해
        var fields = Fields()
        while !rootKeyArray.isAtEnd { //해당 배열에 접근
            let documentKeys = try rootKeyArray.nestedContainer(keyedBy: DocumentKeys.self) //현재 key documents -> key fields
            let fieldKeys = try documentKeys.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields) //fields의 value값에 접근
            fields.title = try fieldKeys.decode(StringValue.self, forKey: .title).value // api에 명시된 key값에 맞춰 변환 후 가져옴
            fields.week = try fieldKeys.decode(StringValue.self, forKey: .week).value
            fields.recommend = try fieldKeys.decode(StringValue.self, forKey: .recommend).value
            fields.division = try fieldKeys.decode(StringValue.self, forKey: .division).value
            fields.weekCount = try fieldKeys.decode(StringValue.self, forKey: .weekCount).value

            documents.append(fields)
        }
    }
}

