//using System;
//using UnityEditor;
//using UnityEngine;

//public class CustomShaderGUI : ShaderGUI
//{
//    MaterialEditor editor;
//    MaterialProperty[] properties;
//    Material target;
//    enum SpecularChoice
//    {
//        True, False
//    }
//    enum ShaderChoice
//    {
//        Normal, Blinn
//    }

//    public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties)
//    {
//        this.editor = editor;
//        this.properties = properties;
//        this.target = editor.target as Material;

//        ShaderChoice shaderChoice = ShaderChoice.Normal;
//        if (!target.IsKeywordEnabled("USE_NORMAL_SHADER"))
//            shaderChoice = ShaderChoice.Blinn;
//        EditorGUI.BeginChangeCheck();
//        shaderChoice = (ShaderChoice)EditorGUILayout.EnumPopup(
//            new GUIContent("Using Shader"), shaderChoice);
//        if (EditorGUI.EndChangeCheck())
//        {
//            if (shaderChoice == ShaderChoice.Normal)
//                target.EnableKeyword("USE_NORMAL_SHADER");
//            else
//                target.DisableKeyword("USE_NORMAL_SHADER");
//        }
//        if (shaderChoice == ShaderChoice.Normal)
//            return;


//        MaterialProperty mainTex = FindProperty("_MainTex", properties);
//        GUIContent mainTexLabel = new GUIContent(mainTex.displayName);
//        editor.TextureProperty(mainTex, mainTexLabel.text);


//        SpecularChoice specularChoice = SpecularChoice.False;
//        if (target.IsKeywordEnabled("USE_SPECULAR"))
//            specularChoice = SpecularChoice.True;
//        EditorGUI.BeginChangeCheck();
//        specularChoice = (SpecularChoice)EditorGUILayout.EnumPopup(
//        new GUIContent("Use Specular?"), specularChoice
//        );
//        if (EditorGUI.EndChangeCheck())
//        {
//            if (specularChoice == SpecularChoice.True)
//                target.EnableKeyword("USE_SPECULAR");
//            else
//                target.DisableKeyword("USE_SPECULAR");
//        }
//        if (specularChoice == SpecularChoice.True)
//        {
//            MaterialProperty specularColor = FindProperty("_SpecularColor", properties);
//            GUIContent specColorLabel = new GUIContent(specularColor.displayName);
//            editor.ColorProperty(specularColor, "Specular Color");


//            MaterialProperty shininess = FindProperty("_Shininess", properties);
//            GUIContent shininessLabel = new GUIContent(shininess.displayName);
//            editor.FloatProperty(shininess, "Specular Factor");
//        }
//    }
//}
