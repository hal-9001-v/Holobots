using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Transform))] 
public class ObjectLookAtScreen : MonoBehaviour
{
    
    Transform thisTransform;
    Camera gameCamera;
    private void Awake() {
      
    }
private void Start() {
    
}
    private void Update() {
        thisTransform = GetComponent<Transform>();
        gameCamera = FindObjectOfType<Camera>();
        thisTransform.LookAt(gameCamera.transform);
        thisTransform.Rotate(0,180,0);
    }

}
