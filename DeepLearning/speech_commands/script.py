from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import os

import tensorflow as tf

import train

training_steps1_list = [3000, 2000, 1000]
training_steps2_list = [1000, 500]

learning_rate1_list = [0.01, 0.005, 0.0025, 0.001]
learning_rate2_list = [0.005, 0.0025, 0.001, 0.0005]

class DictStruct(object):

  def __init__(self, **entries):
    self.__dict__.update(entries)

class TestScript():

    training_steps1 = 0
    training_steps2 = 0
    learning_rate1 = 0
    learning_rate2 = 0

    def testScriptMain(self):
        for ts1 in training_steps1_list:
            for ts2 in training_steps2_list:
                f = open("/content/gdrive/My Drive/saveResult.txt", 'a')
                for lr1 in learning_rate1_list:
                    for lr2 in learning_rate2_list:
                        self.training_steps1 = ts1
                        self.training_steps2 = ts2
                        self.learning_rate1 = lr1
                        self.learning_rate2 = lr2
                        train.FLAGS = self._getDefaultFlags()
                        train.main('')
                        f.write(str(ts1)+'  '+str(ts2)+'    '+ str(lr1)+'   '+str(lr2)+'    %.1f    %d' % (train.hand_over_total_accuracy, train.hand_over_set_size))
                f.close()

    def _getDefaultFlags(self):
        flags = {
            'data_url': '',
            'data_dir': '/content/audio',
            'wanted_words': 'a,ba,ca,cha,da,ga,ha,ja,ma,na,pa,ra,sa,ta',
            'sample_rate': 16000,
            'clip_duration_ms': 1000,
            'window_size_ms': 30,
            'window_stride_ms': 20,
            'feature_bin_count': 40,
            'preprocess': 'mfcc',
            'silence_percentage': 10,
            'unknown_percentage': 10,
            'validation_percentage': 10,
            'testing_percentage': 10,
            'summaries_dir': '/tmp/retrain_logs',
            'train_dir': '/tmp/speech_commands_train',
            'time_shift_ms': 100,
            'how_many_training_steps': str(self.training_steps1)+','+str(self.training_steps2),
            'learning_rate': str(self.learning_rate1)+','+str(self.learning_rate2),
            'quantize': False,
            'model_architecture': 'conv',
            'check_nans': False,
            'start_checkpoint': '',
            'batch_size': 100,
            'background_volume': 0.25,
            'background_frequency': 0.8,
            'eval_step_interval': 400,
            'save_step_interval': 400,
        }
        return DictStruct(**flags)


if __name__ == '__main__':
    mytest = TestScript()
    mytest.testScriptMain()