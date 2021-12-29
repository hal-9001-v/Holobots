using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderTexManager : MonoBehaviour
{
    
    Camera thisCamera;
    [SerializeField] GameObject escenario;
    float fov;
    float minFov;
    float maxFov;
    [SerializeField] float speed;
    void Awake() 
    {
        minFov = 40f;
        maxFov = 90f;
        speed = 25f;
        fov = minFov;
        thisCamera = GetComponent<Camera>();
    }
    // Update is called once per frame
     void FixedUpdate()
    {
        
        fov = minFov+ Mathf.PingPong(Time.time * speed, maxFov-minFov);
        escenario.transform.Rotate(0,Time.deltaTime*10,0);
        thisCamera.fieldOfView = fov; 
    }
}
