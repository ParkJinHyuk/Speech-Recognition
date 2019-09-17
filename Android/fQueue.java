package detection.learn.anish.com.detection3;

import android.util.Log;

import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

/**
 * Created by root on 18. 3. 7.
 *
 * This data structure is a simple queue. This just implements a FIFO queue in JAVA
 *
 *
 */

public class fQueue {
    private List<byte[]> queue;
    private Integer size;

    public fQueue(Integer size) {
        this.queue = Collections.synchronizedList(new LinkedList<byte[]>());
        this.size=size;
    }

    public boolean add(byte[] x) throws Exception {
        if(this.queue.size() < this.size){
            synchronized (this.queue) {
                this.queue.add(x);
            }

//            Log.d("Tag::","Size of Stream:"+this.queue.size());
//            Log.d("Tag::","Original Data:"+ Arrays.toString(x));



//            System.exit(0);
            return true;
        }
        else{
            throw new Exception("Buffer Full");
//            this.remove();
//            this.add(x);
        }

    }

    public byte[] remove() {
        if(this.queue.size()!=0){
            synchronized (this.queue) {
                return this.queue.remove(0);
            }

//            throw new Exception("Buffer Empty! Nothing to return!!!");
        }
        else{
            return null;
        }
//        Log.d("t","Removed");
    }

    public void clear(){
        Log.d("Tag::","Queue Cleared");
        this.queue = null;


    }
    public Integer getSize(){
        return (Integer) this.queue.size();
    }

}
