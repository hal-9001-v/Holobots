using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;
using System;
public class VFXManager : MonoBehaviour
{
    [SerializeField] public VisualEffect VFXObject;
    public VFX[] VFXs;
    public static VFXManager instance;
        // Start is called before the first frame update
    
    private void Awake() {

        if(instance == null) instance = this; else {
            Destroy(gameObject);
            return;
            } 
        DontDestroyOnLoad(this.gameObject);

    }

   public void Play(string searchName, Transform target){


        VFX v = Array.Find(VFXs, vfx => vfx.vfxName == searchName);
        if(v==null) {

            Debug.LogWarning("VFX: " + searchName + " not found!");
            return;
        }
        RealPlay(v, target);
   }

    private void RealPlay(VFX v, Transform target){

        v.vfxObject = VFXObject;
        v.vfxObject.transform.position = v.positionOffset + target.position;
        v.vfxObject.playRate = v.rate;
        v.vfxObject.transform.localScale= v.scale;
        v.vfxObject.visualEffectAsset = v.vfx;
        v.vfxObject.Play();
    }

    public float GetDuration(){
        
//        Debug.Log(VFXObject.GetFloat("Duration"));
        
        return VFXObject.GetFloat("Duration") + 1f;

    }

    
 
}
