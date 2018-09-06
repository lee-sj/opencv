얼굴인식 프로젝트 레일즈에 올리기 / 일반 루비 파일로 실행하기 

먼저 c9에 opencv를 설치해야 한다. 

sudo apt-get update

sudo apt-get install libopencv-dev

gem install ruby-opencv -- --with-opencv-dir=/path/to/opencvdir

먼저 단일 ruby 파일로 실행하는 방법

워크스페이스 최상위에 face.rb 파일을 생성한다.

그리고 나서 https://github.com/ruby-opencv/ruby-opencv 해당 깃헙으로 가서 Face Detection 부분 코드를 복사해온다. 
( * 복사할때 주의할점은 맨아래 3줄은 빼고 복사해온다. 해당코드는 새 창을 띄워서 보여주는것이다. )

복사완료후 실행하는 방법은 쉽다. 
( * 미리 파일에 쓰일 그림파일 한개를 다운받아서 워크스페이스 최상단에 넣어둔다. )

ruby face.rb (그림파일) (새로저장하고자하는 파일이름)

실행했을때 에러가 2개 나온다. 

*해당 에러 메시지 
    libdc1394 error: Failed to initialize libdc1394
    face.rb:10:in `load': invalid format haar classifier cascade file. (ArgumentError)
        from face.rb:10:in `<main>'
첫번째 에러 메시지를 그대로 구글에 검색해본다. 
검색결과에 나온 첫번째 스택오버플로우를 들어가보면 답변이 나와있다. 

sudo ln /dev/null /dev/raw1394

그대로 입력하고 다시 실행한다. 첫번째 에러가 사라진것을 확인할 수 있다. 
두번째 에러를 검색해보자... 뭔소리인지 잘 모를수도 있다.
일단 이 에러가 왜 나왔을찌 에러를 읽어보자 
face.rb 파일의 10번째 줄에서 load할때 argument가 옳지 않다는 에러를 출력한것이다.
그렇다면 해당 위치에 파일열람에 문제가 있거나 파일의 루트가 잘못되었다는 것이다. 
그럼 haarcascade_frontalface_alt.xml 파일이 어디있는지부터 확인해보자. 
확인하기위해서는 최상위폴더로가서 확인해야 정확히 모든 파일을 살펴볼수 있다 우선 cd .. 을 여러번 입력해 최상위로 이동하자

find . -name 'haarcascade_frontalface_alt.xml' 

최상위로 이동후 위의 명령어를 입력하면 최상위폴더에 모든 폴더를 탐색해서 해당 파일을 찾는다는 의미이다. 
입력하면 접근이 불가능한 몇몇곳의 탐색이후 해당 파일의 위치가 나온다.
본인의 예시 코드와 실제 파일의 위치가 다르다는것을 알수있다 해당 루트를 복사해서 코드를 수정한다. 

여기서 주의할것은 맨앞의 . 은현재 폴더를 의미하는데 검색한곳이 최상위이므로 이 . 은 최상위 폴더를 의미한다. 
우리가 ruby 명령어를 통해서 실행하는 위치는 워크스페이스 안쪽이다. 
따라서 이 . 을 삭제한후 실행해야 실제 최상위의 폴더부터 파일을 찾기 시작한다. 
코드를 수정하고 다시 cd ~ 와 cd workspace 를 통해서 우리의 워크스페이스로 이동해온다. 
그리고 다시 코드실행 

코드를 실행하면 본인이 새로저장하고자하는 파일이름으로된 파일이 한개 생성된것을 확인할수 있다. 
사진을 확인하면 얼굴을 찾아서 사각형으로 표시가 된것이 확인된다 이러면 프로젝트 성공