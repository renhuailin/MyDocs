Android开发备忘
--------

Android List View tutorials : http://www.vogella.com/tutorials/AndroidListView/article.html




# Intent 

intent分显式和隐式的
请参考：     
http://developer.android.com/reference/android/content/Intent.html

http://developer.android.com/guide/components/intents-filters.html



```xml
<activity android:name=".MainActivity" android:label="@string/title_activity_main" >
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="oauth" android:host="t4jsample"/>
    </intent-filter>
</activity>
```
