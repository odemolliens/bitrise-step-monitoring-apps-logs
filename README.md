<img align="right" src="assets/icon.svg" width="150" height="150" >

# Bitrise step - Mobile apps logs monitoring

Check if applications contain any logs in the release app
If yes, this step will fail and generate a fail where you can see the count 

!! This step check only the content of an Android app !!

You have to launch this step after [apps-decompiler](https://github.com/imranMnts/bitrise-step-apps-decompiler) to have informations from your APK

We are looking into the APK to be sure to have the **REAL** information because during the development of a mobile application, many libraries can be used and these can add some permissions or useless heavy resources without the consent of the developer. Like that, we can follow up them and be aware when we have any unwanted changes

<br/>

## Usage

Add this step using standard Workflow Editor and provide required input environment variables.

Check if applications contain any logs in the release app
If yes, this step will fail and generate a fail where you can see the count.

<br/>

At the end, it will generate a report file `quality_report.txt`. Just have to launch `deploy-to-bitrise-io` after this step to publish it to your artifacts

## Inputs

The asterisks (*) mean mandatory keys

|Key             |Value type                     |Description    |Default value        
|----------------|-------------|--------------|--------------|
|check_android* |yes/no |Setup - Set yes if you want check Android part|yes|
|check_ios* |yes/no |Setup - Set yes if you want check iOS part|yes|

<br />

### Process to remove all logs from native side

#### Android

To remove all logs from Androoid native part, you have to add this code to your Proguard rules 

```
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}
```