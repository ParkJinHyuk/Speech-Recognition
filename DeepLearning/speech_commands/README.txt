<script.py>
list안의 값을 for문을 돌며 train.py를 실행하는 코드

실행방법

from google.colab import drive
drive.mount('/content/gdrive')
로 자신의 google drive를 연동

전역변수 list 안의 값들을 원하는 값으로 변경해서 저장하고 텐서플로로 실행한다
!python3 /content/speech_commands/script.py

실행 후 saveResult.txt와 여러 개의 intermediateSave...txt가 생성된다

<saveResult.txt>
train.py를 여러 번 실행 후 최종 정확도를 기록한 파일

출력형식 (tab으로 구분되어 있음)

training step1	training step2	learning rate1	learning rate2	accuracy

민희가 지금 돌리고 있는 값

우선 작게 돌린 결과 값
3000 2000 1000
1000 500
0.01 0.005 0.0025 0.001
0.005 0.0025 0.001 0.0005

나중에 크게 돌릴 결과 값
?

<intermediateSave첫번째트레이닝스텝_두번째'’’_첫번째러닝레이트_두번째’’’txt>
각 트레이닝 스텝과 러닝레이트에 따라 중간 기록을 저장한 파일

출력형식 (tab으로 구분되어 있음)

{ [ ] (confusion matrix)
training step	total accuracy	set_size } 400마다 반복
(script.py의 eval_step_interval을 변경해서 변경 가능)
[ ] (confusion matrix)
total accuracy	set_size

