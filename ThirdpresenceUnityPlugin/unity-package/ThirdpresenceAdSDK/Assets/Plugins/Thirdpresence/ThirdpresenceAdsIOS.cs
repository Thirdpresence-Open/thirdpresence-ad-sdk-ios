using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using UnityEngine.Assertions;
using System;
using System.Text.RegularExpressions;

#if UNITY_IPHONE

public delegate void ThirdpresenceInterstitialLoaded();
public delegate void ThirdpresenceInterstitialShown();
public delegate void ThirdpresenceInterstitialDismissed();
public delegate void ThirdpresenceInterstitialFailed(int errorCode, string errorText);
public delegate void ThirdpresenceInterstitialClicked();

public delegate void ThirdpresenceRewardedVideoLoaded();
public delegate void ThirdpresenceRewardedVideoShown();
public delegate void ThirdpresenceRewardedVideoDismissed();
public delegate void ThirdpresenceRewardedVideoFailed(int errorCode, string errorText);
public delegate void ThirdpresenceRewardedVideoClicked();
public delegate void ThirdpresenceRewardedVideoCompleted(string rewardTitle, int rewardAmount);
public delegate void ThirdpresenceRewardedVideoAdLeftApplication();

public class ThirdpresenceAdsIOS : MonoBehaviour
{
	private const string EVENT_HANDLER_OBJECT_NAME = "ThirdpresenceEventHandler";
	private static GameObject eventHandler;

	[DllImport ("__Internal")]
	private static extern void _initInterstitial (string environment, string playerParams, long timeout);

	[DllImport ("__Internal")]
	private static extern void _showInterstitial ();

	[DllImport ("__Internal")]
	private static extern void _removeInterstitial ();

	static ThirdpresenceAdsIOS()
	{
		if( Application.platform != RuntimePlatform.IPhonePlayer )
			return;

		if (eventHandler == null) {
			eventHandler = new GameObject(EVENT_HANDLER_OBJECT_NAME);
			eventHandler.AddComponent<InterstitialListener>();
			eventHandler.AddComponent<RewardedVideoListener> ();
			DontDestroyOnLoad(eventHandler);
		}
	}

	public static event ThirdpresenceInterstitialLoaded OnThirdpresenceInterstitialLoaded;
	public static event ThirdpresenceInterstitialShown OnThirdpresenceInterstitialShown;
	public static event ThirdpresenceInterstitialDismissed OnThirdpresenceInterstitialDismissed;
	public static event ThirdpresenceInterstitialFailed OnThirdpresenceInterstitialFailed;
	public static event ThirdpresenceInterstitialClicked OnThirdpresenceInterstitialClicked;

	public class InterstitialListener : MonoBehaviour {

		public void onInterstitialLoaded() {
			interstitialLoaded = true;
			if (OnThirdpresenceInterstitialLoaded != null) {
				OnThirdpresenceInterstitialLoaded ();
			}
		}

		public void onInterstitialShown() {
			interstitialLoaded = false;
			if (OnThirdpresenceInterstitialShown != null) {
				OnThirdpresenceInterstitialShown ();
			}
		}

		public void onInterstitialDismissed() {
			interstitialLoaded = false;
			if (OnThirdpresenceInterstitialDismissed != null) {
				OnThirdpresenceInterstitialDismissed ();
			}
		}

		public void onInterstitialFailed(string errorData) {
			interstitialLoaded = false;
			Dictionary<string,string> data = ConvertStringToDictionary (errorData);
			int errorCode;
			string errorMsg;
			ParseErrorData (data, out errorCode, out errorMsg);

			if (OnThirdpresenceInterstitialFailed != null) {
				OnThirdpresenceInterstitialFailed (errorCode, errorMsg);
			}
		}

		public void onInterstitialClicked() {
			if (OnThirdpresenceInterstitialClicked != null) {
				OnThirdpresenceInterstitialClicked ();
			}
		}
	}

	public static void InitInterstitial(Dictionary<string, string> environment, Dictionary<string, string> playerParams, long timeout) 
	{
		if( Application.platform != RuntimePlatform.IPhonePlayer )
			return;

		Assert.IsNotNull (environment, "environment argument is null");
		Assert.IsNotNull (playerParams,  "playerParams argument is null");

		_initInterstitial (
			ConvertDictionaryToJSON (environment), 
			ConvertDictionaryToJSON (playerParams), 
			timeout);
	}

	public static void ShowInterstitial()
	{
		if( Application.platform != RuntimePlatform.IPhonePlayer )
			return;

		_showInterstitial ();
	}

	public static void RemoveInterstitial()
	{
		if( Application.platform != RuntimePlatform.IPhonePlayer )
			return;

		_removeInterstitial ();
		interstitialLoaded = false;
	}

	private static bool interstitialLoaded = false;
	public static bool InterstitialLoaded
	{
		get
		{
			return interstitialLoaded;
		}
	}

	public static event ThirdpresenceRewardedVideoLoaded OnThirdpresenceRewardedVideoLoaded;
	public static event ThirdpresenceRewardedVideoShown OnThirdpresenceRewardedVideoShown;
	public static event ThirdpresenceRewardedVideoDismissed OnThirdpresenceRewardedVideoDismissed;
	public static event ThirdpresenceRewardedVideoFailed OnThirdpresenceRewardedVideoFailed;
	public static event ThirdpresenceRewardedVideoClicked OnThirdpresenceRewardedVideoClicked;
	public static event ThirdpresenceRewardedVideoCompleted OnThirdpresenceRewardedVideoCompleted;
	public static event ThirdpresenceRewardedVideoAdLeftApplication OnThirdpresenceRewardedAdLeftApplication;

	[DllImport ("__Internal")]
	private static extern void _initRewardedVideo (string environment, string playerParams, long timeout);

	[DllImport ("__Internal")]
	private static extern void _showRewardedVideo ();

	[DllImport ("__Internal")]
	private static extern void _removeRewardedVideo ();


	public class RewardedVideoListener : MonoBehaviour
	{
		public void onRewardedVideoLoaded() {
			rewardedVideoLoaded = true;
			if (OnThirdpresenceRewardedVideoLoaded != null) {
				OnThirdpresenceRewardedVideoLoaded ();
			}
		}

		public void onRewardedVideoShown() {
			rewardedVideoLoaded = false;
			if (OnThirdpresenceRewardedVideoShown != null) {
				OnThirdpresenceRewardedVideoShown ();
			}
		}

		public void onRewardedVideoDismissed() {
			rewardedVideoLoaded = false;
			if (OnThirdpresenceRewardedVideoDismissed != null) {
				OnThirdpresenceRewardedVideoDismissed ();
			}
		}

		public void onRewardedVideoFailed(string errorData) {
			rewardedVideoLoaded = false;
			Dictionary<string,string> data = ConvertStringToDictionary (errorData);
			int errorCode;
			string errorMsg;
			ParseErrorData (data, out errorCode, out errorMsg);

			if (OnThirdpresenceRewardedVideoFailed != null) {
				OnThirdpresenceRewardedVideoFailed (errorCode, errorMsg);
			}
		}

		public void onRewardedVideoClicked() {
			if (OnThirdpresenceRewardedVideoClicked != null) {
				OnThirdpresenceRewardedVideoClicked ();
			}
		}

		public void onRewardedVideoCompleted(string rewardData) {
			Dictionary<string,string> data = ConvertStringToDictionary (rewardData);
			string rewardTitle;
			int rewardAmount;
			ParseRewardData(data, out rewardTitle, out rewardAmount);
			if (OnThirdpresenceRewardedVideoCompleted != null) {
				OnThirdpresenceRewardedVideoCompleted (rewardTitle, rewardAmount);
			}
		}

		public void onRewardedVideoAdLeftApplication() {
			if (OnThirdpresenceRewardedAdLeftApplication != null) {
				OnThirdpresenceRewardedAdLeftApplication ();
			}
		}
	}

	public static void InitRewardedVideo(Dictionary<string, string> environment, Dictionary<string, string> playerParams, long timeout)
	{
		if( Application.platform != RuntimePlatform.IPhonePlayer )
			return;

		Assert.IsNotNull (environment, "environment argument is null");
		Assert.IsNotNull (playerParams,  "playerParams argument is null");

		_initRewardedVideo (
			ConvertDictionaryToJSON (environment), 
			ConvertDictionaryToJSON (playerParams), 
			timeout);
	}

	public static void ShowRewardedVideo()
	{
		if( Application.platform != RuntimePlatform.IPhonePlayer )
			return;

		_showRewardedVideo ();
	}

	public static void RemoveRewardedVideo()
	{
		if( Application.platform != RuntimePlatform.IPhonePlayer )
			return;

		_removeRewardedVideo ();
		rewardedVideoLoaded = false;
	}

	private static bool rewardedVideoLoaded = false;
	public static bool RewardedVideoLoaded
	{
		get
		{
			return rewardedVideoLoaded;
		}
	}

	private static string ConvertDictionaryToJSON(Dictionary<string,string> dictionary) {

		StringBuilder buffer = new StringBuilder();
		buffer.Append('{');
		bool isFirst = true;
		foreach (KeyValuePair<string,string> pair in dictionary) {
			if (!(pair.Key is string)) {
				throw new ArgumentException("Dictionary keys must be strings", "dictionary");
			}
			if (!(pair.Value is string)) {
				throw new ArgumentException("Dictionary values must be strings", "dictionary");
			}
			if (!isFirst) buffer.Append(',');
			buffer.Append(EncodeString((string)pair.Key));
			buffer.Append(':');
			buffer.Append(EncodeString(pair.Value));
			isFirst = false;
		}
		buffer.Append('}');
		return buffer.ToString();
	}
		
	private static Dictionary<string,string> ConvertStringToDictionary(string str) {
		Dictionary<string,string> dictionary = new Dictionary<string, string> ();
	
		int keyStartIndex = 0;
		int valueStartIndex = 0;
		string key = null;
		string value = null;

		if (str.StartsWith ("{")) {
			for (int i = 1; i < str.Length; i++) {
				if (str [i] == '"' && str [i - 1] != '\\') {
					if (key == null) {
						if (keyStartIndex == 0) {
							keyStartIndex = i + 1;
						} else {
							key = str.Substring (keyStartIndex, i - keyStartIndex);
							key = DecodeString (key);
						}
					} else if (value == null) {
						if (valueStartIndex == 0) {
							valueStartIndex = i + 1;
						} else {
							value = str.Substring (valueStartIndex, i - valueStartIndex);
							value = DecodeString (value);
						}
					}

					if (key != null && value != null) {
						dictionary.Add (key, value);
						key = null;
						value = null;
						keyStartIndex = 0;
						valueStartIndex = 0;
					}
				}
			}
		} 	
			
		return dictionary;
	}

	private static Dictionary<char, string> EscapeChars =
		new Dictionary<char, string>
	{
		{ '"', "\\\"" },
		{ '\\', "\\\\" },
		{ '\b', "\\b" },
		{ '\f', "\\f" },
		{ '\n', "\\n" },
		{ '\r', "\\r" },
		{ '\t', "\\t" },
		{ '\u2028', "\\u2028" },
		{ '\u2029', "\\u2029" }
	};

	private static string EncodeString(string str) {
		StringBuilder buffer = new StringBuilder();
		buffer.Append('"');

		foreach (var c in str) {
			if (EscapeChars.ContainsKey(c)) {
				buffer.Append(EscapeChars[c]);
			} else {
				if (c > 0x80 || c < 0x20) {
					buffer.Append("\\u" + Convert.ToString(c, 16)
						.PadLeft(4, '0'));
				} else {
					buffer.Append(c);
				}
			}
		}
		buffer.Append('"');
		return buffer.ToString();
	}

	private static string DecodeString(string str) {
		string ret = Regex.Replace (str, "\\\\", "\\");
		ret = Regex.Replace (ret, "\\\\\"", "\"");
		ret = Regex.Replace (ret, "\\\\n", "\n");
		ret = Regex.Replace (ret, "\\\\r", "\r");
		ret = Regex.Replace (ret, "\\\\t", "\t");
		ret = Regex.Replace (ret, "\\\\b", "\b");
		ret = Regex.Replace (ret, "\\\\f", "\f");
		ret = Regex.Replace (ret, "\\\\u2028", "\u2028");
		ret = Regex.Replace (ret, "\\\\u2029", "\u2029");
		return ret;
	}

	private static void ParseErrorData(Dictionary<string, string> data, out int errorCode, out string errorMsg) {
		if (data.ContainsKey ("code")) {
			if (!int.TryParse (data ["code"], out errorCode)) {
				errorCode = -1;
			}
		} else {
			errorCode = -1;
		}
			
		errorMsg = data.ContainsKey ("message") ? data ["message"] : "Error message not available for this error";
	}

	private static void ParseRewardData(Dictionary<string, string>  data, out string rewardTitle, out int rewardAmount) {
		int.TryParse (data ["amount"], out rewardAmount);
		rewardTitle = data.ContainsKey ("title") ? data ["title"] : "";
	}
}


#endif
