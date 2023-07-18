# Ricochet Robot Flutter

Flutter를 이용하여 보드게임 Ricochet Robot 개발

### Overview 
- 크로스플랫폼 Flutter를 이용한 앱 개발을 공부하기 위해 평소 즐겨하던 보드게임인 Ricochet Robot을 Dart 언어로 개발하였다. 
- Screen은 크게 초기 화면, 게임 화면, 게임 결과 화면, 기록 화면 4가지로 구성된다.
<table>
  <tr>
    <td>
      초기화면
    </td>
    <td>
      게임 화면
    </td>
    <td>
      게임 결과 화면
    </td>
    <td>
      기록 화면
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://user-images.githubusercontent.com/41365432/217811575-2fd06983-1f0d-4706-a7a9-c4149f69a4e8.gif">
    </td>
    <td>
      <img src="https://user-images.githubusercontent.com/41365432/217811729-d444dae1-c452-4c02-8a6e-8177c8815e84.gif">
    </td>
    <td>
      <img src="https://user-images.githubusercontent.com/41365432/217811772-fb1c4f6d-2cf6-48cb-b73d-5a445291edb3.gif">
    </td>
    <td>
      <img src="https://user-images.githubusercontent.com/41365432/217811694-8f5d4d5c-8109-446b-ade6-eb47e918233b.gif">
    </td>
  </tr>
</table>

- 게임의 주요 요소는 벽(Wall), 말(Piece), 목표(Target) 3가지이다. 이들의 위치는 게임 시작과 동시에 모두 무작위로 설정되어 GridView Widget에 Stack-by-Stack으로 쌓여서 배치된다. 여기서 벽(Wall)의 경우, 생성할 벽의 개수를 조정함으로써 게임의 난이도를 조절할 수 있다.
- 저장이 필요한 이미지는 별도의 Database 없이 앱 내부(Local Path)에 저장한다. 하지만 앱 용량의 증가를 제한하기 위해 특정 개수만큼의 이미지만 저장하도록 설정하였다.
- 복잡하고 효과적인 상태 관리를 위해 Provider를 사용하였다.
- APK 빌드 및 App Bundle 업로드까지 가능하도록 개발하였다.
- 현재는 인터넷 연결 없이 혼자서 게임을 진행할 수 있도록 개발하였지만, 최종 목표는 Ricochet Robot의 한번의 게임 플레이 제한 인원이 무제한인 것 처럼 다수의 인원이 동시에 게임을 진행하는 멀티플레이 형식으로 발전하는 것이다.

</br>
</br>

### Learning Objects
- Flutter 위젯(Widget)의 생명 주기(Life Cycle)을 학습하는 것에 집중한다.
- Native App(본인은 iOS를 이용한 개발에 익숙하다.)과 비슷하지만 조금씩 다른 Flutter 위젯을 학습한다.
- 자주 쓰이는 위젯은 Class화 하여 코드를 효율화한다.
- 제 3자가 코드 리뷰를 하여도 알아볼 수 있도록 최대한 주석(Annotation)을 자주, 자세히 기록한다.
- 외부 Database를 사용하진 않지만, 추후 개발을 위해 어떠한 Database를 사용할 수 있는지 확인한다.

</br>
</br>

### Packages
- provider: ^6.0.5
- cupertino_icons: ^1.0.5
- arrow_pad: ^0.1.4                 // 게임 화면 아래의 말(Piece) 조작 버튼.
- path_provider: ^2.0.11            // 앱 내부 Local Path 접근을 위해 사용.
- screenshot: ^1.3.0                // 게임 화면(Widget) 스크린샷.
- intl: ^0.18.0                     // DataFormat을 위해 사용.
- ntp: ^2.0.0                       // NTP(Network Time Protocol). 네트워크 시간 확인용.
- page_view_indicators: ^2.0.0      // Loading Indicator.
- auto_size_text: ^3.0.0
- flutter_dotenv: ^5.1.0
- google_mobile_ads: ^3.0.0
