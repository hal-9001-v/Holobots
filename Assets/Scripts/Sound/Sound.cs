using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Sound
{
    public AudioClip clip;
    public string name;

    [Range(0f,1f)]
    public float volume;
    [Range(.1f,3f)]
    public float pitch;
    public bool loop; 
    public bool sfx;

    [HideInInspector]
    public AudioSource audioSource;

    [HideInInspector]
    public float time;
}
