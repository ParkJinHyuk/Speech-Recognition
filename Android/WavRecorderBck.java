//package detection.learn.anish.com.detection3;
//
///**
// * Created by user on 1/2/2018.
// * This code is NOT my work. It is COPIED from the following source.
// * Source: http://selvaline.blogspot.kr/2016/04/record-audio-wav-format-android-how-to.html
// */
//
//import android.app.Activity;
//import android.content.Context;
//import android.media.AudioFormat;
//import android.media.AudioRecord;
//import android.media.MediaRecorder;
//import android.os.Environment;
//import android.util.Log;
//import android.widget.EditText;
//
//import java.io.File;
//import java.io.FileInputStream;
//import java.io.FileNotFoundException;
//import java.io.FileOutputStream;
//import java.io.IOException;
//import java.nio.ByteBuffer;
//import java.util.Arrays;
//
//public class WavRecorderBck {
//    private static final int RECORDER_BPP = 16;
//    private static final String AUDIO_RECORDER_FOLDER = "AudioRecorder";
//    private static final String AUDIO_RECORDER_TEMP_FILE = "record_temp.raw";
//    private static final String AUDIO_RECORDER_TEMP_FILE_2 = "record_temp2.raw";
//    private int RECORDER_SAMPLERATE = 192000;
//    private static final int RECORDER_CHANNELS = AudioFormat.CHANNEL_IN_STEREO;
//    private static final int RECORDER_AUDIO_ENCODING = AudioFormat.ENCODING_PCM_16BIT;
//    short[] audioData;
//
//    private AudioRecord recorder = null;
//    private int bufferSize = 0;
//    private Thread recordingThread = null;
//    private boolean isRecording = false;
//    int[] bufferData;
//    int bytesRecorded;
//    Context context;
//
//    private fQueue writeBuffer;
//    private Thread writingThread;
//    String tag="Error-Test-anish: ";
//
//    private String output;
//
//    public WavRecorderBck(String path, Context context) {
//
//        bufferSize = AudioRecord.getMinBufferSize(RECORDER_SAMPLERATE,RECORDER_CHANNELS, RECORDER_AUDIO_ENCODING) * 3;
//        this.context=context;
//        audioData = new short[bufferSize]; // short array that pcm data is put
//        // into.
//        output = path;
//
//    }
//
//    private String getFilename() {
//        EditText name=(EditText) ((Activity)this.context).findViewById(R.id.fileName);
//        EditText number=(EditText) ((Activity)this.context).findViewById(R.id.number);
//        String nameOfTheFile=name.getText().toString()+number.getText().toString()+".wav";
//
//        return (output+nameOfTheFile);
//    }
//    private String getFilename2() {
//        EditText name=(EditText) ((Activity)this.context).findViewById(R.id.fileName);
//        EditText number=(EditText) ((Activity)this.context).findViewById(R.id.number);
//        String nameOfTheFile=name.getText().toString()+number.getText().toString()+"P.wav";
//
//        return (output+nameOfTheFile);
//    }
//
//    private String getTempFilename() {
//        String filepath = Environment.getExternalStorageDirectory().getPath();
//        File file = new File(filepath, AUDIO_RECORDER_FOLDER);
//
//        if (!file.exists()) {
//            file.mkdirs();
//        }
//
//        File tempFile = new File(filepath, AUDIO_RECORDER_TEMP_FILE);
//
//        if (tempFile.exists())
//            tempFile.delete();
//
//        return (file.getAbsolutePath() + "/" + AUDIO_RECORDER_TEMP_FILE);
//    }
//    private String getTempFilename2() {
//        String filepath = Environment.getExternalStorageDirectory().getPath();
//        File file = new File(filepath, AUDIO_RECORDER_FOLDER);
//
//        if (!file.exists()) {
//            file.mkdirs();
//        }
//
//        File tempFile = new File(filepath, AUDIO_RECORDER_TEMP_FILE_2);
//
//        if (tempFile.exists())
//            tempFile.delete();
//
//        return (file.getAbsolutePath() + "/" + AUDIO_RECORDER_TEMP_FILE_2);
//    }
//    public void startRecording() {
//        writeBuffer=new fQueue(1000);
//        EditText name=(EditText) ((Activity)this.context).findViewById(R.id.samplingRateValue);
//
//        RECORDER_SAMPLERATE=Integer.parseInt(name.getText().toString());
//
//
//        recorder = new AudioRecord(MediaRecorder.AudioSource.UNPROCESSED,RECORDER_SAMPLERATE, RECORDER_CHANNELS,RECORDER_AUDIO_ENCODING, bufferSize);
//        int i = recorder.getState();
//        if (i == 1)
//            recorder.startRecording();
//
//        isRecording = true;
//
//        recordingThread = new Thread(new Runnable() {
//            @Override
//            public void run() {
//                writeAudioDataToFile();
//            }
//        }, "AudioRecorder Thread");
//        writingThread= new Thread(new Runnable() {
//            @Override
//            public void run() {
//                threadedWriting();
//            }
//        }, "Writing Thread");
//
//        recordingThread.start();
//        writingThread.start();
//    }
//    private void threadedWriting(){
//        String filename = getTempFilename2();
//        FileOutputStream os1 = null;
//        byte temp[] = new byte[bufferSize];
//        try {
//            os1 = new FileOutputStream(filename);
//        } catch (FileNotFoundException e) {
//            e.printStackTrace();
//        }
//        while(isRecording || this.writeBuffer.getSize()!=0){
//            try {
////                Thread.sleep(300);
//                temp=this.writeBuffer.remove();
//                Log.d("Tag::","Removed Data:"+ Arrays.toString(temp));
//
//
////                Log.d(tag+"-----Writer Thread",Arrays.toString(temp));
//                if(temp==null) {
//                    Log.d(tag,"Thread Empty SLEEPING for  2 sec");
//
//                    Thread.sleep(1);
//                }
//                else{
//                    os1.write(temp);
//                    Log.d(tag,"Written to Disk");
//
//                }
//            } catch (IOException e) {
//                e.printStackTrace();
//            } catch (InterruptedException e) {
//                e.printStackTrace();
//            }
//        }
//
//
//        try {
//            os1.close();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//
//    }
//    private void writeAudioDataToFile() {
//        byte data[] = new byte[bufferSize];
//        String filename = getTempFilename();
//        FileOutputStream os = null;
//
//        try {
//            os = new FileOutputStream(filename);
//        } catch (FileNotFoundException e) {
//            e.printStackTrace();
//        }
//
//        int read = 0;
//        int i=0,j=0;
//        if (isRecording) {
//            while (isRecording) {
//                read = recorder.read(data, 0, bufferSize);
//                Log.d(tag+"---Tag",String.valueOf(i));
//
//                if (AudioRecord.ERROR_INVALID_OPERATION != read) {
//                    try {
//
//                        ByteBuffer b = ByteBuffer.allocate(j++);
////b.order(ByteOrder.BIG_ENDIAN); // optional, the initial order of a byte buffer is always BIG_ENDIAN.
//                        b.putInt(0xAABBCCDD);
//
//                        byte[] result = b.array();
//
//                        this.writeBuffer.add(data.clone());
//                        i=i+1;
// //                       Thread.sleep(1);
////                        os.write(data);
//                    } catch (IOException e) {
//                        e.printStackTrace();
//                    } catch (Exception e) {
//                        e.printStackTrace();
//                    }
//                }
//            }
//
//            try {
//                os.close();
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//        }
//    }
//
//    public void stopRecording() {
//
//
//        if (null != recorder) {
//            isRecording = false;
//
//            int i = recorder.getState();
//            if (i == 1)
//                recorder.stop();
//            recorder.release();
//
//            recorder = null;
//
//            while(writingThread!=null){
//                if(this.writeBuffer.getSize()==0){
//                    Log.d(tag,"Buffer Size 0"+this.writeBuffer.getSize().toString());
//
//                    this.writingThread=null;
//                }
//                try {
//                    Thread.sleep(100);
//                } catch (InterruptedException e) {
//                    e.printStackTrace();
//                }
//
//            }
//
//
//            Log.d(tag,"Writing Thread Killed");
//            this.writingThread=null;
//            recordingThread = null;
//            this.writeBuffer=null;
//        }
//
//        copyWaveFile(getTempFilename(), getFilename());
//        copyWaveFile(getTempFilename2(), getFilename2());
//
//        deleteTempFile();
//    }
//
//    private void deleteTempFile() {
//        File file = new File(getTempFilename());
//        file.delete();
//        file = new File(getTempFilename2());
//        file.delete();
//    }
//
//    private void copyWaveFile(String inFilename, String outFilename) {
//        FileInputStream in = null;
//        FileOutputStream out = null;
//        long totalAudioLen = 0;
//        long totalDataLen = totalAudioLen + 36;
//        long longSampleRate = RECORDER_SAMPLERATE;
//        int channels = ((RECORDER_CHANNELS == AudioFormat.CHANNEL_IN_MONO) ? 1
//                : 2);
//        long byteRate = RECORDER_BPP * RECORDER_SAMPLERATE * channels / 8;
//
//        byte[] data = new byte[bufferSize];
//
//        try {
//            in = new FileInputStream(inFilename);
//            out = new FileOutputStream(outFilename);
//            totalAudioLen = in.getChannel().size();
//            totalDataLen = totalAudioLen + 36;
//
//            WriteWaveFileHeader(out, totalAudioLen, totalDataLen,
//                    longSampleRate, channels, byteRate);
//
//            while (in.read(data) != -1) {
//                out.write(data);
//            }
//
//            in.close();
//            out.close();
//        } catch (FileNotFoundException e) {
//            e.printStackTrace();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//    }
//
//    private void WriteWaveFileHeader(FileOutputStream out, long totalAudioLen,
//                                     long totalDataLen, long longSampleRate, int channels, long byteRate)
//            throws IOException {
//        byte[] header = new byte[44];
//
//        header[0] = 'R'; // RIFF/WAVE header
//        header[1] = 'I';
//        header[2] = 'F';
//        header[3] = 'F';
//        header[4] = (byte) (totalDataLen & 0xff);
//        header[5] = (byte) ((totalDataLen >> 8) & 0xff);
//        header[6] = (byte) ((totalDataLen >> 16) & 0xff);
//        header[7] = (byte) ((totalDataLen >> 24) & 0xff);
//        header[8] = 'W';
//        header[9] = 'A';
//        header[10] = 'V';
//        header[11] = 'E';
//        header[12] = 'f'; // 'fmt ' chunk
//        header[13] = 'm';
//        header[14] = 't';
//        header[15] = ' ';
//        header[16] = 16; // 4 bytes: size of 'fmt ' chunk
//        header[17] = 0;
//        header[18] = 0;
//        header[19] = 0;
//        header[20] = 1; // format = 1
//        header[21] = 0;
//        header[22] = (byte) channels;
//        header[23] = 0;
//        header[24] = (byte) (longSampleRate & 0xff);
//        header[25] = (byte) ((longSampleRate >> 8) & 0xff);
//        header[26] = (byte) ((longSampleRate >> 16) & 0xff);
//        header[27] = (byte) ((longSampleRate >> 24) & 0xff);
//        header[28] = (byte) (byteRate & 0xff);
//        header[29] = (byte) ((byteRate >> 8) & 0xff);
//        header[30] = (byte) ((byteRate >> 16) & 0xff);
//        header[31] = (byte) ((byteRate >> 24) & 0xff);
//        header[32] = (byte) (((RECORDER_CHANNELS == AudioFormat.CHANNEL_IN_MONO) ? 1
//                : 2) * 16 / 8); // block align
//        header[33] = 0;
//        header[34] = RECORDER_BPP; // bits per sample
//        header[35] = 0;
//        header[36] = 'd';
//        header[37] = 'a';
//        header[38] = 't';
//        header[39] = 'a';
//        header[40] = (byte) (totalAudioLen & 0xff);
//        header[41] = (byte) ((totalAudioLen >> 8) & 0xff);
//        header[42] = (byte) ((totalAudioLen >> 16) & 0xff);
//        header[43] = (byte) ((totalAudioLen >> 24) & 0xff);
//
//        out.write(header, 0, 44);
//    }
//}