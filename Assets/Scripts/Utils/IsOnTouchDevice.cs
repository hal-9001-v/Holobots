using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IsOnTouchDevice : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        if(SystemInfo.deviceType == DeviceType.Handheld){

            Debug.Log("Mobile!");

        } 

        else {


            Debug.Log("Desktop!");

        }
        
    }

}
