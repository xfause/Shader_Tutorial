using UnityEngine;

//behaviour which should lie on the same gameobject as the main camera
public class DepthPostprocessing : MonoBehaviour {
    //material that's applied when doing postprocessing
    [SerializeField]
    private Material postprocessMaterial;
    [SerializeField]
    private float waveSpeed;
    [SerializeField]
    private bool waveActive;

    private float waveDistance;

    private void Start(){
        //get the camera and tell it to render a depth texture
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;
    }

    private void Update(){
        if (waveActive){
            waveDistance = waveDistance + waveSpeed * Time.deltaTime;
        } else {
            waveDistance = 0;
        }
    }

    //method which is automatically called by unity after the camera is done rendering
    private void OnRenderImage(RenderTexture source, RenderTexture destination){
        postprocessMaterial.SetFloat("_WaveDistance", waveDistance);
        Graphics.Blit(source, destination, postprocessMaterial);
    }
}