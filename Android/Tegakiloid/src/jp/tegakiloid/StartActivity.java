package jp.tegakiloid;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;
import java.net.SocketException;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;

public class StartActivity extends Activity {
	private final int MENU_SETTING = 1;
	private final int MENU_FINISH  = 2;
	
	private final String initmsg = "0.00000 0.00000";	// 初期メッセージ
	private final String delimitmsg = "end";			// 終了信号
	
	private String address = "127.0.0.1";				// デフォルトIPアドレス
	private int port = 3939;							// みっくみく
	
	private DatagramSocket socket;						// ソケットです
	private InetSocketAddress inetSocketAddress;		// アドレス情報です
	private String message;							// 送信メッセージ(String)です
	private byte[] sendData;							// 送信メッセージ(byte[])です
	private DatagramPacket packet;						// 送信パケットです
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
		try {
			socket = new DatagramSocket();				// ソケット作ります
		} catch (SocketException e) {
			e.printStackTrace();
		}

    }
    
    @Override
    public void onResume() {
    	super.onResume();
		try {
			SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(this);	// プリファレンスから設定情報読んできます
			address = sharedPref.getString("ipaddr", address);									// IPアドレスを取得します
			port = Integer.valueOf((sharedPref.getString("port", String.valueOf(port))));		// ポート番号を取得します
			inetSocketAddress = new InetSocketAddress(address, port);							// IPアドレスとポート番号からアドレス情報を作成します
			sendData = initmsg.getBytes("UTF-8");												// 初期メッセージをUTF-8のバイト配列に変換します
			packet = new DatagramPacket(sendData, 0, sendData.length, inetSocketAddress);		// 変換したバイト配列でパケット作ります
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (SocketException e) {
			e.printStackTrace();
		}
    }
    
    @Override
    public void onDestroy() {
    	super.onDestroy();
    	socket.close();																			// ソケット閉じます
    }
    
    @Override
    public boolean onTouchEvent(MotionEvent event) {
    	super.onTouchEvent(event);
    	message = String.format("%1$03.5f %2$03.5f", event.getX(), event.getY());				// タッチポイントの座標を文字列にします
    	sendMessage(message);																	// 文字列を送信メソッドに渡します
    	return true;
    }
    
    private void sendMessage(String msg) {
		try {
			sendData = msg.getBytes("UTF-8");													// 送信メッセージをUTF-8のバイト配列に変換します
			packet.setData(sendData, 0, sendData.length);										// バイト配列をパケットの送信データに設定します
			socket.send(packet);																// パケット送信！
		} catch (SocketException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
    }
    
    private void setting() {
		String packageName = getApplicationInfo().packageName;									// パッケージ名を取得しています
    	Intent intent = new Intent();															// 画面移動のためのインテントです
    	intent.setClassName(packageName, packageName + ".SetPrefs");							// 画面移動先に設定画面(SetPrefs)をセットします
    	
    	startActivityForResult(intent, RESULT_OK);												// 画面移動します(実はResult貰う必要はない)
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        menu.add(Menu.NONE, MENU_SETTING, Menu.NONE, "設定").setIcon(android.R.drawable.ic_menu_preferences);					// メニュー項目「設定」
        menu.add(Menu.NONE, MENU_FINISH,  Menu.NONE, "終了信号送信").setIcon(android.R.drawable.ic_menu_close_clear_cancel);	// メニュー項目「終了信号送信」
        return super.onCreateOptionsMenu(menu);
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        boolean ret = true;
        switch (item.getItemId()) {						// 選択されたメニューで分岐します
        case MENU_SETTING:								// 設定を選択した場合
        	setting();									// 設定画面を表示するメソッドを呼びます
            ret = true;
            break;
        case MENU_FINISH:								// 終了信号送信を選択した場合
        	sendMessage(delimitmsg);					// 終了信号を送信します
            ret = true;
            break;
        default:
            ret = super.onOptionsItemSelected(item);
            break;
        }
        return ret;
    }
}