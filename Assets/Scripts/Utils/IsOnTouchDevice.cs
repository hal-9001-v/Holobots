using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IsOnTouchDevice : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField] GameObject[] DesktopArray; 
    [SerializeField] GameObject[] HandHeldArray;
     
     private void Awake() {
        
         
    
        if(SystemInfo.deviceType != DeviceType.Handheld){

            Debug.Log("Mobile!");
            foreach(GameObject go in DesktopArray){

                go.SetActive(false);

            } 
             foreach(GameObject go in HandHeldArray){

                go.SetActive(true);

            } 

        } 

        else {

            Debug.Log("Desktop!");
            foreach(GameObject go in DesktopArray){

                go.SetActive(true);

            } 
             foreach(GameObject go in HandHeldArray){

                go.SetActive(false);

            } 
        }
        
    }

}
