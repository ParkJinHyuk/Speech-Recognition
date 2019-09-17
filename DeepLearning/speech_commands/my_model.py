from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import tensorflow as tf

# MNIST 데이터를 다운로드 합니다.
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("/tmp/data/", one_hot=True)

# CNN 모델을 정의합니다. 
def build_CNN_classifier(x):
  # MNIST 데이터를 3차원 형태로 reshape합니다. MNIST 데이터는 grayscale 이미지기 떄문에 3번째차원(컬러채널)의 값은 1입니다. 
  x_image = tf.reshape(x, [-1, 28, 28, 1])

  # 첫번째 Convolution Layer 
  # 5x5 Kernel Size를 가진 32개의 Filter를 적용합니다.
  # 28x28x1 -> 28x28x32
  W_conv1 = tf.Variable(tf.truncated_normal(shape=[5, 5, 1, 32], stddev=5e-2))
  b_conv1 = tf.Variable(tf.constant(0.1, shape=[32]))
  h_conv1 = tf.nn.relu(tf.nn.conv2d(x_image, W_conv1, strides=[1, 1, 1, 1], padding='SAME') + b_conv1)

  # 첫번째 Pooling Layer
  # Max Pooling을 이용해서 이미지의 크기를 1/2로 downsample합니다.
  # 28x28x32 -> 14x14x32
  h_pool1 = tf.nn.max_pool(h_conv1, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')

  # 두번째 Convolutional Layer 
  # 5x5 Kernel Size를 가진 64개의 Filter를 적용합니다.
  # 14x14x32 -> 14x14x64
  W_conv2 = tf.Variable(tf.truncated_normal(shape=[5, 5, 32, 64], stddev=5e-2))
  b_conv2 = tf.Variable(tf.constant(0.1, shape=[64]))
  h_conv2 = tf.nn.relu(tf.nn.conv2d(h_pool1, W_conv2, strides=[1, 1, 1, 1], padding='SAME') + b_conv2)

  # 두번째 Pooling Layer
  # Max Pooling을 이용해서 이미지의 크기를 1/2로 downsample합니다.
  # 14x14x64 -> 7x7x64
  h_pool2 = tf.nn.max_pool(h_conv2, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')

  # Fully Connected Layer
  # 7x7 크기를 가진 64개의 activation map을 1024개의 특징들로 변환합니다. 
  # 7x7x64(3136) -> 1024
  W_fc1 = tf.Variable(tf.truncated_normal(shape=[7 * 7 * 64, 1024], stddev=5e-2))
  b_fc1 = tf.Variable(tf.constant(0.1, shape=[1024]))
  h_pool2_flat = tf.reshape(h_pool2, [-1, 7*7*64])
  h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)

  # Output Layer
  # 1024개의 특징들(feature)을 10개의 클래스-숫자 0-9-로 변환합니다.
  # 1024 -> 10
  W_output = tf.Variable(tf.truncated_normal(shape=[1024, 10], stddev=5e-2))
  b_output = tf.Variable(tf.constant(0.1, shape=[10]))
  logits = tf.matmul(h_fc1, W_output) + b_output
  y_pred = tf.nn.softmax(logits)

  return y_pred, logits