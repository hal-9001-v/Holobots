using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public sealed class MakeSingleton : MonoBehaviour
{
     private static MakeSingleton _instance;

    public static MakeSingleton Instance
    {
        get
        {
            if(_instance == null)
            {
                _instance = GameObject.FindObjectOfType<MakeSingleton>();
            }

            return _instance;
        }
    }

    void Awake()
    {
        if(_instance==null){
             DontDestroyOnLoad(gameObject);
            _instance = this;
        } else Destroy(this);
    
    AudioListener[] audios = FindObjectsOfType<AudioListener>();
    if(audios.Length> 1) Destroy(audios[audios.Length-1]);

    }
}