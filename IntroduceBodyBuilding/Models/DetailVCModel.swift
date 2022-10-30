//
//  VCModel.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/08/19.
//

import Foundation

struct DetailVCModel : Codable{
    
    var documents: [Fields] = []
    
    struct Fields: Codable, Equatable{
        var title: String = ""
        var image: String = ""
        var description: String = ""
        var day: [String] = []
        var routineAtDay: [String] = []
        var url: String = ""
        var author: String = ""
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
    struct ArrayValue: Codable { //firestore api 형식에 맞게 key name set
        let value: [String]
        
        init(value: [String]) {
            self.value = value
        }
        
        private enum CodingKeys: String, CodingKey {
            case value = "values"
        }
    }
    enum RootKey: String, CodingKey {  // nestedContainer로 접근하기 위해
        case documents
    }
    enum DocumentKeys: String, CodingKey{
        case fields
    }
    enum FieldKeys: String, CodingKey{
        case title, image, description, day, routineAtDay, url, author
    }    
    enum ArrayKeys: String, CodingKey{
        case arrayValue
    }
    enum valuesKeys: String, CodingKey{
        case values
    }
}
// MARK: -  FireStore 형식에 맞춰 Decoding

extension DetailVCModel{
    init(from decoder: Decoder) throws {
        let rootKey = try decoder.container(keyedBy: RootKey.self) //document의 value값에 접근 위해
        var rootKeyArray = try rootKey.nestedUnkeyedContainer(forKey: .documents) //value값의 배열 형태에 접근하기 위해
        var fields = Fields()
        while !rootKeyArray.isAtEnd { //해당 배열에 접근
            let documentKeys = try rootKeyArray.nestedContainer(keyedBy: DocumentKeys.self) //현재 key documents -> key fields
            let fieldKeys = try documentKeys.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields) //fields의 value값에 접근
            fields.title = try fieldKeys.decode(StringValue.self, forKey: .title).value // api에 명시된 key값에 맞춰 변환 후 가져옴
            fields.image = try fieldKeys.decode(StringValue.self, forKey: .image).value
            fields.description = try fieldKeys.decode(StringValue.self, forKey: .description).value
            fields.url = try fieldKeys.decode(StringValue.self, forKey: .url).value
            fields.author = try fieldKeys.decode(StringValue.self, forKey: .author).value
            
            try arrayBinding(in: &fields.day, key: .day)
            try arrayBinding(in: &fields.routineAtDay, key: .routineAtDay)
            
            documents.append(fields)

            //day, routineAtDay 필드 [String] 추출
            func arrayBinding(in field: inout[String], key: FieldKeys) throws{
                let arrayKeys = try fieldKeys.nestedContainer(keyedBy: ArrayKeys.self, forKey: key)
                let valuesKey = try arrayKeys.nestedContainer(keyedBy: valuesKeys.self, forKey: .arrayValue)
                var arrayValue = try valuesKey.nestedUnkeyedContainer(forKey: .values)
                
                var array: [String] = []
                while !arrayValue.isAtEnd {
                    let tempString = try arrayValue.decode(StringValue.self).value
                    array.append(tempString)
                }
                field = array
            }
        }
    }
}
