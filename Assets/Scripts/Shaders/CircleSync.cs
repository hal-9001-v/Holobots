using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using System.Linq;
public class CircleSync : MonoBehaviour
{   
    [SerializeField] [Range(0,20)] public float circleSize;
    [SerializeField] [Range(0,1)] public float circleSmoothness;
    [SerializeField] [Range(0,1)] public float circleOpacity;

    public static int PosID = Shader.PropertyToID("_PlayerPos");
    public static int SizeID = Shader.PropertyToID("_Size");
    public static int SmoothID= Shader.PropertyToID("_Smoothness");
    public static int OpID = Shader.PropertyToID("_Opacity");
    public Material[] WallMaterial;
    public Camera Camera;
    public LayerMask Mask;

    Target currentUnit;
    Vector2[] unitMaterials;
    UIInfoManager ui;
    int currentI;

    float timeElapsed;
    float startValue = 0;
    float endValue = 2;
    float lerpDuration = 0.5f;

    Material previous;
    

    private void Start(){
            ui = FindObjectOfType<UIInfoManager>();
            Mask = LayerMask.GetMask("Obstacle");
            Camera = FindObjectOfType<Camera>();
             Obstacle[] ObstacleArray = FindObjectsOfType<Obstacle>();
            WallMaterial = new Material[ObstacleArray.Length];
            for (int i = 0; i < ObstacleArray.Length; i++){
                WallMaterial[i] = ObstacleArray[i].GetComponent<MeshRenderer>().material;
                WallMaterial[i].SetFloat(SizeID, circleSize);
                WallMaterial[i].SetFloat(SmoothID, circleSmoothness);
                WallMaterial[i].SetFloat(OpID ,circleOpacity);

                WallMaterial[i].SetFloat(SizeID,0);
            }   


        }
    private void Update() {

         currentUnit = ui.currentUnitTarget;
        Vector3 currentUnitTransformPosition = new Vector3(currentUnit.transform.position.x, 
        currentUnit.transform.position.y - 1.5f, currentUnit.transform.position.z);
        var dir = Camera.transform.position - currentUnitTransformPosition;
        var ray = new Ray(currentUnitTransformPosition, dir.normalized);
        RaycastHit hit;
         if(Physics.Raycast(ray, out hit, 5000, Mask)){
            int i = 0;
            Material raycastMat = hit.collider.gameObject.GetComponent<MeshRenderer>().material;
            if(raycastMat != null){
                foreach(Material m in WallMaterial){

                if(m == hit.collider.gameObject.GetComponent<MeshRenderer>().material){

                        Debug.Log("Behind");
                        if(timeElapsed < lerpDuration){
                            circleSize = Mathf.Lerp(startValue,endValue, timeElapsed/lerpDuration);
                            timeElapsed += Time.deltaTime;
                            WallMaterial[i].SetFloat(SizeID, circleSize);
                            WallMaterial[i].SetFloat(SmoothID, circleSmoothness);
                            WallMaterial[i].SetFloat(OpID ,circleOpacity);
                            currentI = i;   
                            previous = WallMaterial[i];
                        } else if(WallMaterial[i]!= previous) {
                            
                            timeElapsed = 0;
                        }  

                    }    
                    i++;
                } 
                        
            }    else WallMaterial[i].SetFloat(SizeID, 0);
            
        
        } else{

                for (int i = 0; i < WallMaterial.Length; i++){
                     WallMaterial[i].SetFloat(SizeID, 0);

                Debug.Log("InFront");
                
            }    
        }
    
        
            currentUnit = ui.currentUnitTarget;
            var view = Camera.WorldToViewportPoint(currentUnitTransformPosition);
            for(int j = 0; j < WallMaterial.Length; j++){
                
                WallMaterial[j].SetVector(PosID, view);
            }

        


    }
}
