using UnityEngine;

//behaviour which should lie on the same gameobject as the main camera
public class OutlinesPostprocessed : MonoBehaviour {
    //material that's applied when doing postprocessing
    [SerializeField]
    private Material postprocessMaterial;
    
    private Camera cam;

    private void Start(){
        //get the camera and tell it to render a depth texture
        cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination){
        Graphics.Blit(source, destination, postprocessMaterial);
    }

}