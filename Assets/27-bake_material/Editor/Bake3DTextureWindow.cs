using UnityEditor;
using UnityEngine;
using System.IO;
using System;

public class Bake3DTextureWindow : EditorWindow
{

    Material ImageMaterial;
    string FilePath = "Assets/27-bake_material/MaterialImage3D.asset";
    Vector3Int Resolution;

    bool hasMaterial;
    bool hasResolution;
    bool hasImageFile;

    [MenuItem("Tools/Bake 3d material to texture")]
    static void OpenWindow()
    {
        Bake3DTextureWindow window = EditorWindow.GetWindow<Bake3DTextureWindow>();
        window.Show();
        window.CheckInput();
    }

    void OnGUI()
    {
        using (var check = new EditorGUI.ChangeCheckScope())
        {
            ImageMaterial = (Material)EditorGUILayout.ObjectField("Material", ImageMaterial, typeof(Material), false);
            Resolution = EditorGUILayout.Vector3IntField("Image Resolution", Resolution);
            FilePath = FileField(FilePath);
            if (check.changed)
            {
                CheckInput();
            }
        }

        GUI.enabled = hasMaterial && hasImageFile && hasResolution;
        if (GUILayout.Button("Bake"))
        {
            BakeTexture();
        }
        if (!hasMaterial)
        {
            EditorGUILayout.HelpBox("You're still missing a material to bake.", MessageType.Warning);
        }
        if (!hasResolution)
        {
            EditorGUILayout.HelpBox("Please set a size bigger than zero.", MessageType.Warning);
        }
        if (!hasImageFile)
        {
            EditorGUILayout.HelpBox("No file to save the image to given.", MessageType.Warning);
        }
        GUI.enabled = true;

        EditorGUILayout.HelpBox("Set the material you want to bake as well as the size " +
        "and location of the texture you want to bake to, then press the \"Bake\" button.", MessageType.None);
    }

    string FileField(string path)
    {
        EditorGUILayout.LabelField("Output file");
        using (new GUILayout.HorizontalScope())
        {
            path = EditorGUILayout.TextField(path);
            if (GUILayout.Button("Choose"))
            {
                string directory = "Assets";
                string fileName = "MaterialImage3D.asset";
                try
                {
                    directory = Path.GetDirectoryName(path);
                    fileName = Path.GetFileName(path);
                }
                catch (ArgumentException) { }
                string chosenFile = EditorUtility.SaveFilePanelInProject("Choose image file", fileName,
                "asset", "Please enter a file name to save the image to", directory);
                if (!string.IsNullOrEmpty(chosenFile))
                {
                    path = chosenFile;
                }
                //repaint editor because the file changed and we can't set it in the textfield retroactively
                Repaint();
            }
        }
        return path;
    }

    void BakeTexture()
    {
        RenderTexture renderTexture = RenderTexture.GetTemporary(Resolution.x, Resolution.y);
        Texture3D volumeTexture = new Texture3D(Resolution.x, Resolution.y, Resolution.z, TextureFormat.ARGB32, false);
        Texture2D tempTexture = new Texture2D(Resolution.x, Resolution.y);

        //prepare for loop
        RenderTexture.active = renderTexture;
        int voxelAmount = Resolution.x * Resolution.y * Resolution.z;
        int slicePixelAmount = Resolution.x * Resolution.y;
        Color32[] colors = new Color32[voxelAmount];

        //loop through slices
        for(int slice=0; slice<Resolution.z; slice++){
            //set z coodinate in shader
            float height = (slice + 0.5f) / Resolution.z;
            ImageMaterial.SetFloat("_Height", height);

            //get shader result
            Graphics.Blit(null, renderTexture, ImageMaterial);
            tempTexture.ReadPixels(new Rect(0, 0, Resolution.x, Resolution.y), 0, 0);
            Color32[] sliceColors = tempTexture.GetPixels32();

            //copy slice to data for 3d texture
            int sliceBaseIndex = slice * slicePixelAmount;
            for(int pixel=0; pixel<slicePixelAmount; pixel++){
                colors[sliceBaseIndex + pixel] = sliceColors[pixel];
            }
        }

        //apply and save 3d texture
        volumeTexture.SetPixels32(colors);
        AssetDatabase.CreateAsset(volumeTexture, FilePath);

        //clean up variables
        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(renderTexture);
        DestroyImmediate(volumeTexture);
        DestroyImmediate(tempTexture);
    }

    void CheckInput()
    {
        hasMaterial = ImageMaterial != null;
        hasResolution = Resolution.x > 0 && Resolution.y > 0 && Resolution.z > 0;
        hasImageFile = false;
        try
        {
            string ext = Path.GetExtension(FilePath);
            hasImageFile = ext.Equals(".asset");
        }
        catch (ArgumentException) { }
    }
}
