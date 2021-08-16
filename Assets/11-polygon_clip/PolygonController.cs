using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class PolygonController : MonoBehaviour
{

    [SerializeField]
    private Vector2[] corners;

    private Material _mat;

    void UpdateMaterial()
    {
        if (_mat == null)
        {
            _mat = GetComponent<Renderer>().sharedMaterial;
        }
        Vector4[] vec4Corners = new Vector4[1000];
        for (int i = 0; i < corners.Length; i++)
        {
            vec4Corners[i] = corners[i];
        }

        //pass array to material
        _mat.SetVectorArray("_corners", vec4Corners);
        _mat.SetInt("_cornerCount", corners.Length);
    }

    void Start(){
        UpdateMaterial();
    }

    void OnValidate(){
        UpdateMaterial();
    }
}