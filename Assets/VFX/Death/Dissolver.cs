using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Dissolver : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(0, 5)] public float _dissolveTime = 1;

    private Renderer[] _renderers;

    const string DissolveKey = "_DissolveAmount";

    private void Awake()
    {
        _renderers = GetComponentsInChildren<Renderer>();

    }
 
    [ContextMenu("Dissolve")]
    public void DissolveC(){

        Dissolve(null);

    }    
    public void Dissolve(CountBarrier barrier)
    {
        StartCoroutine(DissolveOverTime(barrier));
    }

    public IEnumerator DissolveOverTime(CountBarrier barrier)
    {
        float counter = 0;

        if (_renderers != null && _renderers.Length != 0)
        {
            while (counter < _dissolveTime)
            {
                foreach (var renderer in _renderers)
                {
                   foreach(Material m in renderer.materials) m.SetFloat(DissolveKey, counter / _dissolveTime);
                }

                counter += Time.deltaTime;

                yield return null;
            }
        }

        foreach (var renderer in _renderers)
        {
            renderer.material.SetFloat(DissolveKey, 1);
        }

        if (barrier != null)
        {
            barrier.RemoveCounter();
        }
    }


}
