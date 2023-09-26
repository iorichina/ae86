package iorichina.minicardemo;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Matrix;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;

import java.net.InetAddress;
import java.net.SocketAddress;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.ByteBuffer;

public class Esp32CameraFragment extends Fragment {

    final String TAG = "ExCameraFragment";
    final byte[] mRequestConnect = new byte[]{'w', 'h', 'o', 'a', 'm', 'i'};
    final byte[] mRequestForward = new byte[]{'f', 'o', 'r', 'w', 'a', 'r', 'd'};
    final byte[] mRequestForwardTrack = new byte[]{'f', 'w', 't', 'r', 'a', 'c', 'k'};
    final byte[] mRequestBackward = new byte[]{'b', 'a', 'c', 'k', 'w', 'a', 'r', 'd'};
    final byte[] mRequestLeft = new byte[]{'l', 'e', 'f', 't'};
    final byte[] mRequestLeftTrack = new byte[]{'l', 'e', 'f', 't', 't', 'r', 'a', 'c', 'k'};
    final byte[] mRequestRight = new byte[]{'r', 'i', 'g', 'h', 't'};
    final byte[] mRequestRightTrack = new byte[]{'r', 'i', 'g', 'h', 't', 't', 'r', 'a', 'c', 'k'};
    final byte[] mRequestStop = new byte[]{'s', 't', 'o', 'p'};
    final byte[] mRequestCamUp = new byte[]{'c', 'a', 'm', 'u', 'p'};
    final byte[] mRequestCamDown = new byte[]{'c', 'a', 'm', 'd', 'o', 'w', 'n'};
    final byte[] mRequestCamLeft = new byte[]{'c', 'a', 'm', 'l', 'e', 'f', 't'};
    final byte[] mRequestCamRight = new byte[]{'c', 'a', 'm', 'r', 'i', 'g', 'h', 't'};
    final byte[] mRequestCamStill = new byte[]{'c', 'a', 'm', 's', 't', 'i', 'l', 'l'};
    final byte[] mLedOn = new byte[]{'l', 'e', 'd', 'o', 'n'};
    final byte[] mLedOff = new byte[]{'l', 'e', 'd', 'o', 'f', 'f'};

    UDPSocket camUdpClient;
    InetAddress camAddr;
    int camPort = 86;
    int camLedPort = 6868;
    WebSocketClient camWebSocketClient;
    boolean camStreamOn = false;
    boolean camLedOn = false;

    InetAddress carServerAddr;
    int carServerPort = 9998;
    WebSocketClient carWebSocketClient;
    Handler carHandler = new Handler() {
        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
        }
    };
    Runnable carRunnable = new Runnable() {
        @Override
        public void run() {
            //要做的事情
            carHandler.post(this);
            carHandler.postDelayed(this, 300);
        }
    };

    ImageView camImageView;
    Button ledBtn;
    Button streamBtn;
    ImageButton mBackMoveBtn;
    ImageButton mForMoveBtn;
    ImageButton mRightMoveBtn;
    ImageButton mLeftMoveBtn;
    EditText ipInputCam;
    EditText ipInputCar;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        camUdpClient = new UDPSocket(12345);
        camUdpClient.runUdpServer();

    }

    private String hex(int i) {
        String s = Integer.toHexString(i);
        if (s.length() < 2) {
            return "0" + s;
        }
        return s;
    }

    private void carCtrl(Boolean left, Boolean forward) {
        if (null == carWebSocketClient || !carWebSocketClient.isOpen()) {
            return;
        }
        //#top_left,top_right,bottom_left,bottom_right
        StringBuilder sb = new StringBuilder("#");
        if (null == forward) {
            sb.append(hex(0)).append(hex(0));
            sb.append(hex(0)).append(hex(0));
        } else if (forward) {
            //go
            if (null == left) {
                sb.append(hex(255)).append(hex(255));
                sb.append(hex(0)).append(hex(0));
            }
            //go left
            else if (left) {
                sb.append(hex(0)).append(hex(255));
                sb.append(hex(255)).append(hex(0));
            }
            //go right
            else {
                sb.append(hex(255)).append(hex(0));
                sb.append(hex(0)).append(hex(255));
            }
        } else {
            //back
            if (null == left) {
                sb.append(hex(0)).append(hex(0));
                sb.append(hex(255)).append(hex(255));
            }
            //back left
            else if (left) {
                sb.append(hex(255)).append(hex(0));
                sb.append(hex(0)).append(hex(255));
            }
            //back right
            else {
                sb.append(hex(0)).append(hex(255));
                sb.append(hex(255)).append(hex(0));
            }
        }
        carWebSocketClient.send(sb.toString());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup parent, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_camera, parent, false);
        camImageView = (ImageView) rootView.findViewById(R.id.imageView);

        ledBtn = (Button) rootView.findViewById(R.id.ledBtn);
        streamBtn = (Button) rootView.findViewById(R.id.streamBtn);
        ipInputCam = rootView.findViewById(R.id.cam_ip_input);
        ipInputCar = rootView.findViewById(R.id.car_ip_input);

        FragmentActivity activity = getActivity();
        SharedPreferences sp = activity.getSharedPreferences(Esp32CameraFragment.class.getSimpleName(), Context.MODE_PRIVATE);
        String camIp = sp.getString("cam_ip", ipInputCam.getText().toString());
        ipInputCam.setText(camIp);
        String carIp = sp.getString("car_ip", ipInputCar.getText().toString());
        ipInputCar.setText(carIp);

        streamBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 连接cam
                connect2CamWebSocket();

                // connect to car
                connect2CarWebSocket();
            }
        });

        ledBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!camStreamOn) {
                    return;
                }
                if (!camLedOn) {
                    camLedOn = true;
                    ledBtn.setBackgroundResource(android.R.drawable.presence_online);
                    ledBtn.setTextColor(Color.rgb(0, 0, 255));
                    camUdpClient.sendBytes(camAddr, camLedPort, mLedOn);
                } else {
                    camLedOn = false;
                    ledBtn.setBackgroundResource(android.R.drawable.presence_invisible);
                    ledBtn.setTextColor(Color.rgb(255, 255, 255));
                    camUdpClient.sendBytes(camAddr, camLedPort, mLedOff);
                }
            }
        });

        ImageButton.OnTouchListener listener = new ImageButton.OnTouchListener() {
            Boolean left, forward;

            @Override
            public boolean onTouch(View arg0, MotionEvent event) {
                ImageButton moveBtn = (ImageButton) arg0;
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    //横屏向前
                    if (moveBtn.getId() == R.id.forwardMoveBtn) {
                        moveBtn.setImageResource(R.drawable.ic_btn_forward_on);
                        camUdpClient.sendBytes(camAddr, camLedPort, mRequestForward);
                        forward = true;
                    }
                    //向后
                    else if (moveBtn.getId() == R.id.backwardMoveBtn) {
                        moveBtn.setImageResource(R.drawable.ic_btn_backward_on);
                        camUdpClient.sendBytes(camAddr, camLedPort, mRequestBackward);
                        forward = false;
                    }
                    //向左
                    else if (moveBtn.getId() == R.id.leftMoveBtn) {
                        moveBtn.setImageResource(R.drawable.ic_btn_left_on);
                        camUdpClient.sendBytes(camAddr, camLedPort, mRequestLeft);
                        left = true;
                    }
                    //向右
                    else if (moveBtn.getId() == R.id.rightMoveBtn) {
                        moveBtn.setImageResource(R.drawable.ic_btn_right_on);
                        camUdpClient.sendBytes(camAddr, camLedPort, mRequestRight);
                        left = false;
                    }
                    // car control
                    carCtrl(left, forward);
                    return true;
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    //横屏向前
                    if (moveBtn.getId() == R.id.forwardMoveBtn) {
                        moveBtn.setImageResource(R.drawable.ic_btn_forward_off);
                        forward = null;
                    }
                    //向后
                    else if (moveBtn.getId() == R.id.backwardMoveBtn) {
                        moveBtn.setImageResource(R.drawable.ic_btn_backward_off);
                        forward = null;
                    }
                    //向左
                    else if (moveBtn.getId() == R.id.leftMoveBtn) {
                        moveBtn.setImageResource(R.drawable.ic_btn_left_off);
                        left = null;
                    }
                    //向右
                    else if (moveBtn.getId() == R.id.rightMoveBtn) {
                        moveBtn.setImageResource(R.drawable.ic_btn_right_off);
                        left = null;
                    }
                    camUdpClient.sendBytes(camAddr, camLedPort, mRequestStop);
                    camUdpClient.sendBytes(camAddr, camLedPort, mRequestStop);
                    // car control
                    carCtrl(left, forward);
                    return true;
                }
                return false;
            }
        };

        mBackMoveBtn = (ImageButton) rootView.findViewById(R.id.backwardMoveBtn);
        mBackMoveBtn.setOnTouchListener(listener);
        mForMoveBtn = (ImageButton) rootView.findViewById(R.id.forwardMoveBtn);
        mForMoveBtn.setOnTouchListener(listener);
        mRightMoveBtn = (ImageButton) rootView.findViewById(R.id.rightMoveBtn);
        mRightMoveBtn.setOnTouchListener(listener);
        mLeftMoveBtn = (ImageButton) rootView.findViewById(R.id.leftMoveBtn);
        mLeftMoveBtn.setOnTouchListener(listener);

        return rootView;
    }

    private void connect2CamWebSocket() {
        // 正在拉视频的则停掉，否则开始拉视频
        if (camStreamOn) {
            ipInputCam.setVisibility(View.VISIBLE);
            streamBtn.setBackgroundResource(android.R.drawable.presence_video_away);
            if (null != camWebSocketClient) {
                camWebSocketClient.close();
            }
            camStreamOn = false;
            return;
        }

        FragmentActivity activity = getActivity();
        String val = ipInputCam.getText().toString();
        val = val.replace("cam:", "").trim();
        if (val.isEmpty()) {
            Toast.makeText(activity, "请输入摄像头ip", Toast.LENGTH_SHORT).show();
            return;
        }

        //获得SharedPreferences的实例 sp_name是文件名
        SharedPreferences sp = activity.getSharedPreferences(Esp32CameraFragment.class.getSimpleName(), Context.MODE_PRIVATE);
//获得Editor 实例
        SharedPreferences.Editor editor = sp.edit();
//以key-value形式保存数据
        editor.putString("cam_ip", ipInputCam.getText().toString());
//apply()是异步写入数据
        editor.apply();
//commit()是同步写入数据
//editor.commit();

        String[] split = val.split(":");
        String camIp = split[0];
        camLedPort = split.length > 1 ? Integer.parseInt(split[1]) : camLedPort;

        try {
            camAddr = InetAddress.getByName(camIp);
        } catch (Exception e) {
            Toast.makeText(activity, "请输入正确的ip地址", Toast.LENGTH_SHORT).show();
            return;
        }
        Toast.makeText(activity, "Connecting to Cam " + camAddr.toString() + ":" + camLedPort, Toast.LENGTH_LONG).show();

        // led控制--whoami
        camUdpClient.sendBytes(camAddr, camLedPort, mRequestConnect);
        Pair<SocketAddress, String> res = camUdpClient.getResponse();
        int cnt = 30;
        while (res.first == null && cnt > 0) {
            res = camUdpClient.getResponse();
            cnt--;
        }

        // 连不上cam的ip
//        if (res.first == null) {
//            Toast.makeText(activity,
//                    "Cannot connect to ESP32 Camera " + camIp + ":" + camPort
//                            + " by visiting led controller " + camAddr.toString() + ":" + camLedPort
//                            + " with error " + camUdpClient.latestError,
//                    Toast.LENGTH_LONG).show();
//            return;
//        }

//        Log.d(TAG, res.first.toString() + ":" + res.second);
        camStreamOn = true;
        ipInputCam.setVisibility(View.INVISIBLE);
        streamBtn.setBackgroundResource(android.R.drawable.presence_video_busy);

        URI uri;
        try {
            uri = new URI("ws://" + camIp + ":" + camPort + "/");
        } catch (URISyntaxException e) {
            Toast.makeText(activity,
                    "Cannot connect to Camera Websocket ws://" + camIp.toString() + ":" + camPort
                            + "/ with error " + e.toString(),
                    Toast.LENGTH_LONG).show();
            return;
        }

        camWebSocketClient = new WebSocketClient(uri) {
            @Override
            public void onOpen(ServerHandshake serverHandshake) {
                Log.d("Websocket", "Stream Open");
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity, "Stream Open", Toast.LENGTH_LONG).show();
                    }
                });
            }

            @Override
            public void onClose(int i, String s, boolean b) {
                Log.d("Websocket", "Stream Closed " + s);
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity, "Stream Closed " + s, Toast.LENGTH_LONG).show();
                    }
                });
            }

            @Override
            public void onMessage(String message) {
                Log.d("Websocket", "Stream Receive " + message);
            }

            @Override
            public void onMessage(ByteBuffer message) {
                // Log.d("Websocket", "Receive");
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        byte[] imageBytes = new byte[message.remaining()];
                        message.get(imageBytes);
                        final Bitmap bmp = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
                        if (bmp == null) {
                            return;
                        }
                        int viewWidth = camImageView.getWidth();
                        Matrix matrix = new Matrix();
                        matrix.postRotate(90);
                        final Bitmap bmp_traspose = Bitmap.createBitmap(bmp, 0, 0, bmp.getWidth(), bmp.getHeight(),
                                matrix, true);
                        float imagRatio = (float) bmp_traspose.getHeight() / (float) bmp_traspose.getWidth();
                        int dispViewH = (int) (viewWidth * imagRatio);
                        camImageView.setImageBitmap(Bitmap.createScaledBitmap(bmp_traspose, viewWidth, dispViewH, false));
                    }
                });
            }

            @Override
            public void onError(Exception e) {
                Log.d("Websocket", "Stream Error " + e.getMessage());
            }
        };
        try {
            camWebSocketClient.connect();
        } catch (Exception e) {
            Toast.makeText(activity, "Cam Connect Error " + e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }

    private void connect2CarWebSocket() {
        // 正在拉视频的则开始连接小车，否则断开连接
        if (!camStreamOn) {
            ipInputCar.setVisibility(View.VISIBLE);
            if (null != carWebSocketClient) {
                carWebSocketClient.close();
            }
            return;
        }

        FragmentActivity activity = getActivity();
        String val = ipInputCar.getText().toString();
        val = val.replace("car:", "").trim();
        if (val.isEmpty()) {
            Toast.makeText(activity, "请输入小车ip", Toast.LENGTH_SHORT).show();
            return;
        }

        //获得SharedPreferences的实例 sp_name是文件名
        SharedPreferences sp = activity.getSharedPreferences(Esp32CameraFragment.class.getSimpleName(), Context.MODE_PRIVATE);
//获得Editor 实例
        SharedPreferences.Editor editor = sp.edit();
//以key-value形式保存数据
        editor.putString("car_ip", ipInputCar.getText().toString());
//apply()是异步写入数据
        editor.apply();
//commit()是同步写入数据
//editor.commit();

        String[] split = val.split(":");
        String carIP = split[0];
        carServerPort = split.length > 1 ? Integer.parseInt(split[1]) : carServerPort;

        try {
            carServerAddr = InetAddress.getByName(carIP);
        } catch (Exception e) {
            Toast.makeText(activity, "请输入正确的ip地址", Toast.LENGTH_SHORT).show();
            return;
        }
        Toast.makeText(activity, "Connecting to Car " + carServerAddr.toString() + ":" + carServerPort, Toast.LENGTH_LONG).show();

        ipInputCar.setVisibility(View.INVISIBLE);

        URI uri;
        try {
            uri = new URI("ws://" + carIP + ":" + carServerPort + "/");
        } catch (URISyntaxException e) {
            Toast.makeText(activity,
                    "Cannot connect to Car websocket ws://" + carIP + ":" + carServerPort
                            + "/ with error " + e.toString(),
                    Toast.LENGTH_LONG).show();
            return;
        }

        Toast.makeText(activity, "Connecting to Car WebSocketClient " + uri.toString(), Toast.LENGTH_LONG).show();
        carWebSocketClient = new WebSocketClient(uri) {

            @Override
            public void onOpen(ServerHandshake serverHandshake) {
                Log.d("Websocket", "Car Control Open");
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity, "Car Control Open", Toast.LENGTH_LONG).show();
                    }
                });
            }

            @Override
            public void onClose(int i, String s, boolean b) {
                Log.d("Websocket", "Car Control Closed " + s);
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity, "Car Control Closed " + s, Toast.LENGTH_LONG).show();
                    }
                });
            }

            @Override
            public void onMessage(String message) {
                Log.d("Websocket", "Car Control Receive String:" + message);
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity, "Car Control message " + message, Toast.LENGTH_LONG).show();
                    }
                });
            }

            @Override
            public void onMessage(ByteBuffer message) {
                byte[] imageBytes = new byte[message.remaining()];
                message.get(imageBytes);
                String s = new String(imageBytes);
                Log.d("Websocket", "Car Control Receive ByteBuffer:" + s);
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity, "Car Control ByteBuffer " + s, Toast.LENGTH_LONG).show();
                    }
                });
            }

            @Override
            public void onError(Exception e) {
                Log.d("Websocket", "Car Control Error " + e.getMessage());
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity, "Car Control Error " + e.getMessage(), Toast.LENGTH_LONG).show();
                    }
                });
            }
        };
        try {
            carWebSocketClient.connect();
        } catch (Exception e) {
            Toast.makeText(activity, "Car Connect Error " + e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }

    public void onDestroy() {
        Log.e(TAG, "onDestroy");
        if (null != camWebSocketClient) {
            camWebSocketClient.close();
        }
        if (null != carWebSocketClient) {
            carWebSocketClient.close();
        }
        super.onDestroy();
    }

}
