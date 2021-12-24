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

    [SerializeField] VFX _explosionVFX;
    [SerializeField] VFX _healVFX;
    [SerializeField] VFX _sparkVFX;
    [SerializeField] VFX _smokeVFX;
    [SerializeField] VFX _lightingVFX;

    public void PlayExplosion(Transform target)
    {
        RealPlay(_explosionVFX, target);
    }

    public void PlayHeal(Transform target)
    {
        RealPlay(_healVFX, target);
    }

    public void PlaySpark(Transform target)
    {
        RealPlay(_sparkVFX, target);
    }

    private void RealPlay(VFX v, Transform target)
    {

        _VFXObject.transform.position = v.positionOffset + target.position;

        _VFXObject.playRate = v.rate;

        _VFXObject.transform.localScale = v.scale;
        _VFXObject.visualEffectAsset = v.vfx;

        _VFXObject.Play();
    }

    public float GetDuration()
    {
        return _VFXObject.GetFloat(DurationPropertyKey) + 1f;
    }



}
