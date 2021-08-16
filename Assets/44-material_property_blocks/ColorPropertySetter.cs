using UnityEngine;

public class ColorPropertySetter : MonoBehaviour
{
    public Color MaterialColor;

    private MaterialPropertyBlock propertyBlock;

    void OnValidate(){
        if (propertyBlock == null) {
            propertyBlock = new MaterialPropertyBlock();
        }
        Renderer renderer = GetComponentInChildren<Renderer>();
        //set the color property
        propertyBlock.SetColor("_Color", MaterialColor);
        //apply propertyBlock to renderer
        renderer.SetPropertyBlock(propertyBlock);
    }
}
