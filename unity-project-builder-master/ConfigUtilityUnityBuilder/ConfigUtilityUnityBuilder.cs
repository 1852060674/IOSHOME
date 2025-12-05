using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace ConfigUtilityUnityBuilder {
    public class ProjectBuild : Editor {

        public class BuildParams {
            public string ks;
            public string ks_pass;
            public string ks_key_alias;
            public string ks_key_pass;
            public string save_path;
            public string compress;
            public bool appbundle;
            public bool debugkey;
            public bool developmentBuild;
            public bool symbolexport;

            public BuildParams(string[] args) {
                debugkey = false;
                appbundle = false;
                symbolexport = false;
                for (int i = 0; i < args.Length; i++) {
                    Debug.Log(args[i]);
                    if (args[i].Equals("--debugkey")) {
                        debugkey = true;
                    } else if (args[i].Equals("--symbol")) {
                        symbolexport = true;
                    } else if (args[i].Equals("--appbundle")) {
                        appbundle = true;
                    } else if (i < args.Length - 1) {
                        if (args[i].Equals("--ks")) {
                            ks = args[i + 1];
                            i++;
                        } else if (args[i].Equals("--ks-pass")) {
                            ks_pass = args[i + 1];
                            i++;
                        } else if (args[i].Equals("--ks-key-alias")) {
                            ks_key_alias = args[i + 1];
                            i++;
                        } else if (args[i].Equals("--key-pass")) {
                            ks_key_pass = args[i + 1];
                            i++;
                        } else if (args[i].Equals("--compress")) {
                            compress = args[i + 1];
                            i++;
                        } else if (args[i].Equals("--output")) {
                            save_path = args[i + 1];
                            i++;
                        }
                    }
                }

                if (debugkey) {
                    ks = DebugKeyStorePath;
                    ks_pass = "android";
                    ks_key_alias = "androiddebugkey";
                    ks_key_pass = "android";
                }
            }

            public bool isValid() {
                return !(string.IsNullOrEmpty(ks)
                    || string.IsNullOrEmpty(ks_pass)
                    || string.IsNullOrEmpty(ks_key_alias)
                    || string.IsNullOrEmpty(ks_key_pass));
            }

            private static string DebugKeyStorePath {
                get {
                    return (Application.platform == RuntimePlatform.WindowsEditor) ?
                        System.Environment.GetEnvironmentVariable("USERPROFILE") + @"\.android\debug.keystore" :
                        System.Environment.GetFolderPath(System.Environment.SpecialFolder.Personal) + @"/.android/debug.keystore";
                }
            }
        }

        [MenuItem("Tools/Test Build Script/Build Android Debug Apk")]
        private static void BuildAndroidDebug() {
            string filename = EditorUtility.SaveFilePanel("Save to ...", System.IO.Directory.GetCurrentDirectory(), "app-release", "apk");
            BuildParams buildParams = new BuildParams(new string[] { "--output", filename, "--debugkey" });
            buildParams.developmentBuild = true;
            buildWithParams(buildParams);
        }

        [MenuItem("Tools/Test Build Script/Build Android Debug Aab")]
        private static void BuildAndroidDebugAab() {
            string filename = EditorUtility.SaveFilePanel("Save to ...", System.IO.Directory.GetCurrentDirectory(), "app-release", "aab");
            BuildParams buildParams = new BuildParams(new string[] { "--output", filename, "--debugkey", "--appbundle" });
            buildParams.developmentBuild = true;
            buildWithParams(buildParams);
        }

        [MenuItem("Tools/Test Build Script/Build Android Debug Aab(with Symbol)")]
        private static void BuildAndroidDebugAabWithSymbol() {
            string filename = EditorUtility.SaveFilePanel("Save to ...", System.IO.Directory.GetCurrentDirectory(), "app-release", "aab");
            BuildParams buildParams = new BuildParams(new string[] { "--output", filename, "--debugkey", "--appbundle", "--symbol" });
            buildParams.developmentBuild = true;
            buildWithParams(buildParams);
        }

        static string[] GetBuildScenes() {
            List<string> names = new List<string>();
            foreach (EditorBuildSettingsScene e in EditorBuildSettings.scenes) {
                if (e == null)
                    continue;
                if (e.enabled)
                    names.Add(e.path);
            }
            return names.ToArray();
        }

        static void BuildForAndroid() {
            BuildParams buildParams = new BuildParams(System.Environment.GetCommandLineArgs());
            if (!buildParams.isValid()) {
                Debug.Log("Need specify keystore file and output file dir");
                Debug.Log(buildParams.ks);
                Debug.Log(buildParams.ks_pass);
                Debug.Log(buildParams.ks_key_alias);
                Debug.Log(buildParams.ks_key_pass);
                Debug.Log(buildParams.save_path);
                throw new System.Exception();
            }

            buildWithParams(buildParams);
        }

        static private void buildWithParams(BuildParams buildParams) {
            Debug.Log(string.Format("Sign using file {0}, keyalias {1}", buildParams.ks, buildParams.ks_key_alias));

            string path;
            if (System.IO.Directory.Exists(buildParams.save_path)) {
                path = buildParams.save_path + "/app-released.apk";
            } else {
                path = buildParams.save_path;
            }

            if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android) {
#if UNITY_2017_1_OR_NEWER
                EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
#else
                EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTarget.Android);
#endif
            }
            EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;

#if UNITY_2018_3_OR_NEWER
        if(buildParams.appbundle) {
            EditorUserBuildSettings.buildAppBundle = true;
            if(path.EndsWith(".apk", System.StringComparison.CurrentCulture)) {
                path = path.Substring(0, path.Length - 4) + ".aab";
            }
        } else {
            EditorUserBuildSettings.buildAppBundle = false;
        }
#endif

        if(buildParams.symbolexport) {
            EditorUserBuildSettings.androidCreateSymbolsZip = true;
        }

#if UNITY_2018
        // Change adaptive icon, no need in default
        //var kind = UnityEditor.Android.AndroidPlatformIconKind.Adaptive;
        //var icons = PlayerSettings.GetPlatformIcons(BuildTargetGroup.Android, kind);
        //Texture2D icon = (Texture2D)AssetDatabase.LoadAssetAtPath("Assets/Pictures2/ICON/换皮icon2-432x432.png", typeof(Texture2D));
        //if (icon == null) {
        //    Debug.LogError("can't find android adaptive icon");
        //    throw new System.Exception();
        //}
        //icons[0].SetTexture(icon);
        //PlayerSettings.SetPlatformIcons(BuildTargetGroup.Android, UnityEditor.Android.AndroidPlatformIconKind.Adaptive, icons);
#endif
#if UNITY_2019_1_OR_NEWER
            PlayerSettings.Android.useCustomKeystore = true;
#endif
            PlayerSettings.Android.keystoreName = buildParams.ks.Replace('\\', '/');
            PlayerSettings.Android.keystorePass = buildParams.ks_pass;
            PlayerSettings.Android.keyaliasName = buildParams.ks_key_alias;
            PlayerSettings.Android.keyaliasPass = buildParams.ks_key_pass;

            BuildPlayerOptions options = new BuildPlayerOptions();
            options.scenes = GetBuildScenes();
            options.target = BuildTarget.Android;
            options.locationPathName = path;
            if(buildParams.developmentBuild) {
                options.options = BuildOptions.Development | BuildOptions.AllowDebugging;
            } else {
                options.options = BuildOptions.None;
            }
            if(buildParams.compress != null) {
                if (buildParams.compress.Equals("lz4")) {
                    options.options |= BuildOptions.CompressWithLz4;
                } else if (buildParams.compress.Equals("lz4hc")) {
                    options.options |= BuildOptions.CompressWithLz4HC;
                } else if (!buildParams.compress.Equals("")) {
                    Debug.Log("Unknwon compress: " + buildParams.compress + ", use default");
                }
            }
#if UNITY_2018_3_OR_NEWER
        var error = BuildPipeline.BuildPlayer(options);
        if (error.summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
        {
            Debug.Log("Build succeeded: " + error.summary.totalSize + " bytes");
        }

        if (error.summary.result == UnityEditor.Build.Reporting.BuildResult.Failed)
        {
            Debug.LogError(error.summary.ToString());
            throw new System.Exception();
        }
#else
            string error = BuildPipeline.BuildPlayer(options);

            if (!string.IsNullOrEmpty(error)) {
                Debug.LogError(error);
                throw new System.Exception();
            }
#endif
        }
    }
}
