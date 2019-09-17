package detection.learn.anish.com.detection3;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.media.SoundPool;
import android.os.AsyncTask;
import android.os.Environment;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Switch;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.Socket;
import java.net.URL;
import java.net.URLConnection;
import java.net.UnknownHostException;

import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.RECORD_AUDIO;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class MainActivity extends AppCompatActivity {
    static int cout = 0;
    public static Button startRecording;
    String tag = "Log::";
    WavRecorder recorder = new WavRecorder("/sdcard/AudioRecorder/",this);
    public static final int RequestPermissionCode = 1;
    public static Context mContext;
    TCP_Client tc;

    public static class TCP_Client extends AsyncTask{
        protected static String SERV_IP = "165.194.27.192";
//        protected static String SERV_IP = "192.168.142.138";
        protected static int PORT = 8080;

        @Override
        protected Object doInBackground(Object[] objects) {

            try {
                InetAddress serverAddr = InetAddress.getByName(SERV_IP);
                Socket sock = new Socket(serverAddr, PORT);

                File file = new File("/sdcard/AudioRecorder/record.wav");

                DataInputStream dis = new DataInputStream(new FileInputStream(file));
                DataOutputStream dos = new DataOutputStream(sock.getOutputStream());

                long fileSize = file.length();
                byte[] buf = new byte[1024];

                long totalReadBytes = 0;
                int readBytes;

                while((readBytes = dis.read(buf)) > 0) {
                    dos.write(buf, 0, readBytes);
                    totalReadBytes += readBytes;
                }

                dos.close();


            } catch (UnknownHostException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }


            return null;
        }
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        startRecording = (Button) findViewById(R.id.startRecording);
        mContext = this;



        startRecording.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){

                if (!checkPermission())
                    requestPermission();

                Log.d(tag,"Start Recording");
                recorder.startRecording();

                startRecording.setEnabled(false);
            }
        });
        }


    public void setRecordingButton() {
        while(true) {
            if(!recorder.isRecording()) {
                startRecording.setEnabled(true);
                break;
            }
        }
    }

    public void sendFile() {
        tc = new TCP_Client();
        tc.execute(this);
    }

    private void requestPermission() {
        ActivityCompat.requestPermissions(MainActivity.this, new
                String[]{WRITE_EXTERNAL_STORAGE, RECORD_AUDIO,READ_EXTERNAL_STORAGE}, RequestPermissionCode);


    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case RequestPermissionCode :
                if (grantResults.length> 0) {

                    boolean StoragePermission = grantResults[0] == PackageManager.PERMISSION_GRANTED;
                    boolean RecordPermission = grantResults[1] == PackageManager.PERMISSION_GRANTED;
                    boolean ReadStoragePermission = grantResults[2] == PackageManager.PERMISSION_GRANTED;


                    if (StoragePermission && RecordPermission && ReadStoragePermission) {
                        Toast.makeText(MainActivity.this, "Permission Granted", Toast.LENGTH_LONG).show();
                    } else {
                        Toast.makeText(MainActivity.this,"Permission Denied",Toast.LENGTH_LONG).show();
                    }
                }
                break;
        }
    }

    public boolean checkPermission() {
        int result2 = ContextCompat.checkSelfPermission(getApplicationContext(),
                READ_EXTERNAL_STORAGE);
        int result = ContextCompat.checkSelfPermission(getApplicationContext(),
                WRITE_EXTERNAL_STORAGE);
        int result1 = ContextCompat.checkSelfPermission(getApplicationContext(),
                RECORD_AUDIO);
        return result2 == PackageManager.PERMISSION_GRANTED &&
                result == PackageManager.PERMISSION_GRANTED &&
                result1 == PackageManager.PERMISSION_GRANTED;
    }

}

