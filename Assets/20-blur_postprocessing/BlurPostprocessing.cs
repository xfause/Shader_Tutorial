using UnityEngine;

//behaviour which should lie on the same gameobject as the main camera
public class BlurPostprocessing : MonoBehaviour {
    //material that's applied when doing postprocessing
    [SerializeField]
    private Material postprocessMaterial;

    private void Start(){
    
    }

    private void Update(){
        
    }

    //method which is automatically called by unity after the camera is done rendering
    private void OnRenderImage(RenderTexture source, RenderTexture destination){
        var tempTexture = RenderTexture.GetTemporary(source.width, source.height);
        Graphics.Blit(source, tempTexture, postprocessMaterial, 0);
        Graphics.Blit(tempTexture, destination, postprocessMaterial, 1);
        RenderTexture.ReleaseTemporary(tempTexture);
    }
}