using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Transform))] 
public class ObjectLookAtScreen : MonoBehaviour
{
    
    Transform thisTransform;
    Camera gameCamera;
    private void Awake() {
        thisTransform = GetComponent<Transform>();
        gameCamera = FindObjectOfType<Camera>();
    }

    private void Update() {
        thisTransform.LookAt(gameCamera.transform);
        thisTransform.Rotate(0,180,0);
    }

}
