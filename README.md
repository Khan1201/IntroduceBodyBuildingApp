![waving](https://capsule-render.vercel.app/api?type=waving&height=150&text=루틴모아&fontSize=60&fontAlign=15&fontAlignY=40&color=gradient)
 <img width="20%" src="https://user-images.githubusercontent.com/87113698/204698245-7deb66fc-1086-47b9-8135-112435214140.png"/> 
 ### :heavy_exclamation_mark: 현재 앱스토어 심사중 :heavy_exclamation_mark:

<br>

## 프로젝트 정보 :floppy_disk:
> <p> 기간 : <b>2022년 8월 19일 ~ 2022년 11월 29일 (약 3개월)</b> </p>
> <p> 맴버 : <b>HyeongSeok Yun (1명)</b> </p>

<br>

## 프로젝트 동기 :hammer:
> ios 개발 공부를 시작하고, 처음으로 진행한 헬스 관련 개인 프로젝트입니다. 평소 운동을 즐겨하기도 하고, 제가 직접 운동하며 `리프터`의 입장으로 현재 헬스 업계 앱 시장에 부족한 부분을 생각해 왔었습니다. 현재 서비스 중인 헬스 앱에서 제공하는 프로그램은 대부분 유료이며, 저뿐만 아니라 대부분의 '헬서'들이 쉽게 접근할 수 없었습니다. 다수의 많은 '헬서' 분들이 쉽게 접하고 즐겼으면 하는 마음에 프로젝트를 기획하게 되었습니다.

<br>

## 프로젝트 소개 📝
> 세계 운동학자들이 만들어낸 무료 공개 운동 프로그램을 앱에 담았습니다. 사용자는 다양한 운동 프로그램들을 볼 수 있으며, 자신의 무게를 적용하여 직접 프로그램 루틴을 체험해 볼 수 있습니다. 체험에 도움을 주기 위해, 알람 기능 및 메모 기능을 추가했습니다. 사용자는 원하는 시간대에 운동을 즐길 수 있고, 자신의 운동 수행에 관한 메모를 할 수 있습니다. 해당 프로젝트에 <b>Rx Swfit + MVVM</b> 및 다양한 오픈소스들을 활용하였습니다.

<br>

## 구조 :book:
> <img width="20%" src="https://user-images.githubusercontent.com/87113698/204721799-15952d5a-52dc-44ef-9900-e537abc2ce6e.png"/>
<br>

## 사용한 기술 🔥
<img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"> <img src="https://img.shields.io/badge/UIkit-2396F3?style=for-the-badge&logo=UIkit&logoColor=white">
<img src="https://img.shields.io/badge/CocoaPods-EE3322?style=for-the-badge&logo=CocoaPods&logoColor=white"> <img src="https://img.shields.io/badge/FireStore-FFCA28?style=for-the-badge&logo=FireBase&logoColor=white">

> ### CocoaPods
- RxSwift, RxCocoa, RxRelay
- Alamofire
- Snapkit
- Then
- DeviceKit
- DropDown

<br>

## 달성한 목표 👏

> ### Json Decode
- 까다로운 JSON 형태로 유명한 Fire Store의 API 데이터 형태를 디코딩하였습니다. 먼저 JSON 형태를 Struct로 정의하고, 루트 키를 .container로 접근하였습니다. 그리고 .nested Container로 하위 키에 순차적으로 접근하였습니다.

<br>

> ### RxSwift + MVVM
- RxSwift + MVVM 기술을 사용하여 ViewController의 독립성을 증가시켰습니다. 이로써, 분리된 ViewModel을 다른 ViewController에 적용할 수 있었고, 코드 유지보수에 간결함이 더해졌습니다. 

<br>

> ### String 문자열 다루기
- API를 통해 받아오는 루틴 데이터에 사용자의 무게를 적용해야 했습니다. API 데이터의 줄바꿈(\n)의 Index를 구하여 한 라인별로 접근하고, 해당 라인에 조건 값을 넣어 문자열을 대치하였습니다.

<br>

> ### AutoLayout + Code Base
- AutoLayout의 Constraint 및 priority 속성에 익숙해져, 다양한 기기에 UI 대응이 수월해졌습니다. 그리고 AutoLayout으로 수행하기 까다로운 것들을 Code 베이스로 구성하여, 코드로도 UI를 구성할 수 있습니다.

<br>

> ### URL Scheme를 통한 외부 앱 호출
- 외부 앱의 URL Scheme를 추출하여, 해당 인스턴스를 만들고 접근했습니다. 외부 앱이 설치되었다면 계속 진행, 설치되어있지 않았다면 외부 앱의 앱 스토어 주소를 호출하였습니다.

<br>

> ### 등등..

<br>

## 아쉬운 점 💦

> ### 코드 리팩터링
- 나름 효율적으로 코드를 구성했다고 생각했으나, 다른 사람들의 코드를 보았을 때 아직 한참 부족하다고 느꼈습니다. 조금 더 많은 사람의 코드를 보고, 이유 있는 코드 리팩터링에 대한 방향을 잡을 계획입니다.

<br>

> ### UI 구성
- 최대한 예쁘고, 깔끔하게 UI를 구성해 보았으나, 현재 서비스 중인 타사 앱의 UI에 비해 많이 뒤처지는 것 같습니다. 물론 디자이너가 관여되지 않았지만, 앞으로의 앱을 출시하기에 디자이너분과 소통에 차질이 생기지 않도록 지속적인 Figma 및 UIKit 학습으로 보완할 계획입니다.

<br>

> ### 기획
- 처음에 나름의 고민에 고민을 거쳐 기획했던 내용들이 말처럼 쉽지 않았습니다. 말하는 대로의 구현에 한계가 있었고, 그 한계를 깨우치는데 직접 만들어보면서 느꼈습니다. 좀 더 확실한 계획과 다양한 지식을 토대로 `안되는 기능`을 쉽게 파악할 수 있도록 보완할 계획입니다.

<br>

> ### 각 운동 프로그램별 변동성
- 프로그램별 변동성이 매우 커 데이터 구조화에 많은 힘이 들었습니다. 각 프로그램 저자별로 개인적인 부분이 많이 들어가므로, 많은 알고리즘이 요구되었습니다. (예를 들면, A 프로그램은 10주 계획에 주차 별로 + 10% 중량이 증가하고, B 프로그램은 7주 계획에 주차 별로 중량 증가 없이 횟수가 증가합니다.)

<br>

## 앱 화면 💻
> |   홈    |  상세화면 1  |
> | :-----: | :------: |
> |  <img width="250" height="600" src="https://user-images.githubusercontent.com/87113698/204705846-0ae29908-edbc-4d8b-93e6-3f8d1785bd44.png"/>  | <img width="250" height="600" src="https://user-images.githubusercontent.com/87113698/204706801-fe8b5553-3c2a-41ed-9e94-74686eaa904d.png"/> |

<br>

> |  상세화면 2   |  루틴  |
> | :----: | :----: |
> | <img width="250" height="600" src="https://user-images.githubusercontent.com/87113698/204707910-20dc2fb2-ca3a-4a12-b5e6-5dfd85699a91.png"/> | <img width="250" height="600" src="https://user-images.githubusercontent.com/87113698/204707106-f8018b02-b102-40fe-ba3d-52056ccc50d0.png"/> |

<br>

> |  보관함   |  설정  |
> | :----: | :----: |
> | <img width="250" height="600" src="https://user-images.githubusercontent.com/87113698/204707485-a8313ad2-da71-4232-bf32-0e0865face90.png"/> | <img width="250" height="600" src="https://user-images.githubusercontent.com/87113698/204708211-cb104d15-d92b-4e88-9416-85e5d493747f.png"/> |

<br>
