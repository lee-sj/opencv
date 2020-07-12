얼굴인식 프로젝트 
=
#### 먼저 c9에 opencv를 설치해야 한다. 
```
$ sudo apt-get update
 
$ sudo apt-get install libopencv-dev
 
After this operation, 131 MB of additional disk space will be used.
Do you want to continue? [Y/n] Y
```
### 1. 단일 ruby 파일로 실행하는 방법

워크스페이스 최상위에 face.rb 파일을 생성한다.  
google 에 ruby opencv를 검색해서 'Versioned fork of the OpenCV gem for Ruby - GitHub'  
해당 사이트로 들어가서 gem 형태로 다운 받는다
```
$ gem install ruby-opencv -- --with-opencv-dir=/path/to/opencvdir
```
그리고 나서 Face Detection 부분 코드를 복사해온다.
```
require 'opencv'
include OpenCV

if ARGV.length < 2
  puts "Usage: ruby #{__FILE__} source dest"
  exit
end

data = './data/haarcascades/haarcascade_frontalface_alt.xml'
detector = CvHaarClassifierCascade::load(data)
image = CvMat.load(ARGV[0])
detector.detect_objects(image).each do |region|
  color = CvColor::Blue
  image.rectangle! region.top_left, region.bottom_right, :color => color
end

image.save_image(ARGV[1])
```
복사후 바로 실행해보자.
```
$ ruby face.rb pic.jpg output.jpg
```
pic.jpg : 본인 그림파일  
output.jpg : 결과 파일  

실행했을때 에러가 2개 나온다. 

    libdc1394 error: Failed to initialize libdc1394
    face.rb:10:in `load': invalid format haar classifier cascade file. (ArgumentError)
        from face.rb:10:in `<main>'

첫줄의 에러 메시지를 그대로 구글에 검색해본다.  
검색결과에 나온 첫번째 스택오버플로우를 들어가보면 답변이 나와있다.   
구글신을 찬양하라 :)
```
sudo ln /dev/null /dev/raw1394
```
그대로 입력하고 다시 실행하면 첫번째 에러가 사라진것을 확인할 수 있다.  
두번째 에러를 검색해보자... 뭔소리인지 잘 모를수도 있다.  
일단 이 에러가 왜 나왔을지 에러를 읽어보자  
face.rb 파일 10번째 줄에서 load할때 argument가 옳지 않다는 에러를 출력한것이다.  
해당 위치에 파일열람에 문제가 있거나 파일의 루트가 잘못되었다는 것이다.  
그럼 haarcascade_frontalface_alt.xml 파일이 어디있는지부터 확인해보자. 
확인하는 방법

```
find / -name 'haarcascade_frontalface_alt.xml' (루트 폴더터 하위폴더 검색)
```
입력하면 접근이 불가능한 몇몇곳의 탐색이후 해당 파일의 위치가 나온다.  
예시 코드와 실제 파일의 위치가 다르다는것을 알수있다.  
해당 루트를 복사해서 코드를 수정한다.  
그리고 다시 코드실행 

```
$ ruby face.rb pic.jpg output.jpg
```
실행이후 종료되는것이 확인되면 같은 폴더위치에 output.jpg가 생성된것을 확인할수 있다.  
face detect 말고 다른 기능도 확인해보자!

```
haarcascade_eye.xml                  haarcascade_frontalface_alt_tree.xml  haarcascade_lowerbody.xml          haarcascade_mcs_lefteye.xml   haarcascade_mcs_righteye.xml      haarcascade_smile.xml
haarcascade_eye_tree_eyeglasses.xml  haarcascade_frontalface_default.xml   haarcascade_mcs_eyepair_big.xml    haarcascade_mcs_mouth.xml     haarcascade_mcs_upperbody.xml     haarcascade_upperbody.xml
haarcascade_frontalface_alt.xml      haarcascade_fullbody.xml              haarcascade_mcs_eyepair_small.xml  haarcascade_mcs_nose.xml      haarcascade_profileface.xml
haarcascade_frontalface_alt2.xml     haarcascade_lefteye_2splits.xml       haarcascade_mcs_leftear.xml        haarcascade_mcs_rightear.xml  haarcascade_righteye_2splits.xml
```
### 2. 레일즈에 올리는 방법

레일즈에 올리기위해 간단한 컨트롤러를 한개 만들어준다.  
```
rails g controller home index photos
```

Gemfile에 gem 추가
```
gem 'ruby-opencv' # bundle
```

index.html에 input form 을 만들고 photos 액션을 통해서 사진을 넘겨줄것이다.  
photos 액션에 단일 ruby에서 썻던 코드들을 복사해서 컨트롤러로 가지고 온다.  

해당 두줄은 컨트롤러 맨앞으로 가져온다.
```
require 'opencv'
include OpenCV
```
photos 액션 
```
data = '/usr/share/opencv/haarcascades/haarcascade_frontalface_alt.xml'
detector = CvHaarClassifierCascade::load(data)
image = CvMat.load(ARGV[0])
detector.detect_objects(image).each do |region|
  color = CvColor::Blue
  image.rectangle! region.top_left, region.bottom_right, :color => color
end

image.save_image(ARGV[2])
```

이부분 가지고 오기 
다른것은 고치는것 없고 rails 를 통해서 파일을 업로드 하므로 
ARGV부분을 바꾸어 주어야 한다.우선 ARGV[0] 을 비어있는 파람즈로 바꿔주고 params[] 
그리고 마지막 부분에서 이미지를 세이브할 이름으로 지정해준다. 그전에는 실행할때 저장이름을 넘겨줬지만 
여기서는 지정해주도록하자 "output.jpg"

그리고 view에서 input form을 만들어준다. 

    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
    <!-- Optional theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">
    <!-- Latest compiled and minified JavaScript -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>

bootstrap다운받든 cdn 으로 설치하든 설치안하든 이건 본인편한대로하고  
div.container>div.row>form>div (tab) 하고 다른 코드들 채워주자

    <div class="container">
        <div class="row">
            <form action="/home/photos" method="POST" enctype="multipart/form-data">
                <div>
                    <label>File input</label>
                    <input name="input_file" type="file" ></input>
                </div>
                <button type="submit">Submit</button>
            </form>
        </div>
    </div>


사진 한장을 폼으로 넘겨보자
error 페이지 > routing error > confing/routes.rb
```
post '/home/photos'
```
error > 어플리케이션 컨트롤러 프로텍트 주석처리 < 헬퍼를 쓰지않고 테스트하는 중이니 그냥 이부분은 주석하고 넘어가자  
파일을 보내고 나서 에러가 나오므로 파일을 세이브하고 나서 리다이렉트를 시켜준다. 
```
redirect_to '/'
```
파일이 정장저장된것을 확인할수있다.  
그리고 레일즈를 굳이 사용해서 opencv를 한다면 그것은 웹서비스를 하는것이므로  
이를 본인의 서버에 저장할것이 아니라 서비스 이용자에게 다운받을수 있게 해주어야 한다.  
해당 코드는 send_file("output.jpg") 이다.  
해당 photos 액션을 실행후 할 랜더링 행동에 send_file과 redirect_to 로 두개가 되었으므로 리다이렉트를 지워준다.  
그러면 파일을 전송하고나서 사진을 저장하는 행동을 실행한다.  

send_file의 속성을 한가지 더 알려주고 마친다.   
dipostion 속성  
  send_file("output.jpg", disposition: 'inline')  
  으로 inline 을 준다면 파일이 웹화면에 뜨게되는 속성이다.  
