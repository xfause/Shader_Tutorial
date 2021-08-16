using UnityEditor;
using UnityEngine;
using System.IO;
using System;

public class BakeTextureWindow : EditorWindow
{

    Material ImageMaterial;
    string FilePath = "Assets/27-bake_material/MaterialImage.png";
    Vector2Int Resolution;

    bool hasMaterial;
    bool hasResolution;
    bool hasImageFile;

    [MenuItem("Tools/Bake material to texture")]
    static void OpenWindow()
    {
        BakeTextureWindow window = EditorWindow.GetWindow<BakeTextureWindow>();
        window.Show();
        window.CheckInput();
    }

    void OnGUI()
    {
        using (var check = new EditorGUI.ChangeCheckScope())
        {
            ImageMaterial = (Material)EditorGUILayout.ObjectField("Material", ImageMaterial, typeof(Material), false);
            Resolution = EditorGUILayout.Vector2IntField("Image Resolution", Resolution);
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
                string fileName = "MaterialImage.png";
                try
                {
                    directory = Path.GetDirectoryName(path);
                    fileName = Path.GetFileName(path);
                }
                catch (ArgumentException) { }
                string chosenFile = EditorUtility.SaveFilePanelInProject("Choose image file", fileName,
                "png", "Please enter a file name to save the image to", directory);
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
        Graphics.Blit(null, renderTexture, ImageMaterial);

        Texture2D texture = new Texture2D(Resolution.x, Resolution.y);
        RenderTexture.active = renderTexture;
        texture.ReadPixels(new Rect(Vector2.zero, Resolution), 0, 0);

        byte[] png = texture.EncodeToPNG();
        File.WriteAllBytes(FilePath, png);
        AssetDatabase.Refresh();

        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(renderTexture);
        DestroyImmediate(texture);
    }

    void CheckInput()
    {
        hasMaterial = ImageMaterial != null;
        hasResolution = Resolution.x > 0 && Resolution.y > 0;
        hasImageFile = false;
        try
        {
            string ext = Path.GetExtension(FilePath);
            hasImageFile = ext.Equals(".png");
        }
        catch (ArgumentException) { }
    }
}
