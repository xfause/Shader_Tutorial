using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Postprocessing : MonoBehaviour
{
    [SerializeField]
    private Material postprocessMaterial;

    void OnRenderImage(RenderTexture source, RenderTexture destination){
        Graphics.Blit(source, destination, postprocessMaterial);
    }
}
