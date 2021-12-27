using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;
using System;
public class VFXManager : MonoBehaviour
{
    [SerializeField] VisualEffect _VFXObject;

    const string DurationPropertyKey = "Duration";

    public VisualEffect VFXObject
    {
        get
        {
            return _VFXObject;
        }
    }

    [SerializeField] VFX[] vfxes;

    public void Play(String vfxs, Transform target, Quaternion rotation)
    {
        VFX v =  Array.Find(vfxes, vfx => vfx.name == vfxs);
        if (v.name == "")
        {
            Debug.LogWarning("VFX: " + v.name + " not found!");
            return;
        }
        _VFXObject.transform.position = v.positionOffset + target.position;
        _VFXObject.transform.rotation  = rotation;

        _VFXObject.transform.localScale = v.scale;
        _VFXObject.visualEffectAsset = v.vfx;
        
        _VFXObject.Play();
    }

    public float GetDuration()
    {
        return _VFXObject.GetFloat(DurationPropertyKey) + 1f;
    }



}
