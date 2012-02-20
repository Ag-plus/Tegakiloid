package jp.tegakiloid;

import android.os.Bundle;
import android.preference.PreferenceActivity;

public class SetPrefs extends PreferenceActivity {
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		addPreferencesFromResource(R.xml.prefs);	// xmlを作れば勝手に設定画面を作ってくれるのですっ！便利ですっ＞＜b
		setResult(RESULT_OK, null);
	}
}
