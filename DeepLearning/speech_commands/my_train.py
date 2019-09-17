from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import tensorflow as tf

import os

import my_model

# 인풋 아웃풋 데이터를 받기위한 플레이스홀더를 정의합니다.
x = tf.placeholder(tf.float32, shape=[None, 784])
y = tf.placeholder(tf.float32, shape=[None, 10])

# Convolutional Neural Networks(CNN)을 선언합니다.
y_pred, logits = my_model.build_CNN_classifier(x)

# Cross Entropy를 손실 함수(loss function)으로 정의하고 옵티마이저를 정의합니다.
loss = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(labels=y, logits=logits))
train_step = tf.train.AdamOptimizer(1e-4).minimize(loss)

# 정확도를 계산하는 연산을 추가합니다.
correct_prediction = tf.equal(tf.argmax(y_pred, 1), tf.argmax(y, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

# tf.train.Saver를 이용해서 모델과 파라미터를 저장합니다.
SAVER_DIR = "model"
saver = tf.train.Saver()
checkpoint_path = os.path.join(SAVER_DIR, "model")
ckpt = tf.train.get_checkpoint_state(SAVER_DIR)

# 세션을 열어 실제 학습을 진행합니다.
with tf.Session() as sess:
  # 모든 변수들을 초기화합니다.
  sess.run(tf.global_variables_initializer())

  # 만약 저장된 모델과 파라미터가 있으면 이를 불러오고 (Restore)
  # Restored 모델을 이용해서 테스트 데이터에 대한 정확도를 출력하고 프로그램을 종료합니다.
  if ckpt and ckpt.model_checkpoint_path:
    saver.restore(sess, ckpt.model_checkpoint_path)    
    print("테스트 데이터 정확도 (Restored) : %f" % accuracy.eval(feed_dict={x: mnist.test.images, y: mnist.test.labels}))
    sess.close()
    exit()

  # 10000 Step만큼 최적화를 수행합니다.
  for step in range(10000):
    # 50개씩 MNIST 데이터를 불러옵니다.
    batch = mnist.train.next_batch(50)
    # 100 Step마다 training 데이터셋에 대한 정확도를 출력하고 tf.train.Saver를 이용해서 모델과 파라미터를 저장합니다.
    if step % 100 == 0:      
      saver.save(sess, checkpoint_path, global_step=step)
      train_accuracy = accuracy.eval(feed_dict={x: batch[0], y: batch[1]})
      print("반복(Epoch): %d, 트레이닝 데이터 정확도: %f" % (step, train_accuracy))
    # 옵티마이저를 실행해 학습을 진행합니다.
    sess.run([train_step], feed_dict={x: batch[0], y: batch[1]})

  # 학습이 끝나면 테스트 데이터에 대한 정확도를 출력합니다.
  print("테스트 데이터 정확도: %f" % accuracy.eval(feed_dict={x: mnist.test.images, y: mnist.test.labels}))