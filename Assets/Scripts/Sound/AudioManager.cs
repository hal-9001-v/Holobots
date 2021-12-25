using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Audio;
public class AudioManager : MonoBehaviour
{
    public static AudioManager instance;
    public Sound[] sounds;
    [SerializeField] AudioMixerGroup music;
    [SerializeField] AudioMixerGroup sfx;
    private void Awake()
    {
        if(instance == null) {
            instance = this;
            DontDestroyOnLoad(this.gameObject);
        } else Destroy(this.gameObject);

        foreach (Sound s in sounds)
        {
            s.audioSource = gameObject.AddComponent<AudioSource>();
            s.audioSource.clip = s.clip;
            s.audioSource.volume = s.volume;
            s.audioSource.pitch = s.pitch;
            s.audioSource.loop = s.loop;
            if(s.sfx) s.audioSource.outputAudioMixerGroup = sfx;
            else s.audioSource.outputAudioMixerGroup = music;
        }
        Play("TestMusic");
    }

    public void Play(string name)
    {
        Sound s = Array.Find(sounds, sound => sound.name == name);
        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found!");
            return;
        }
        if (s.audioSource != null) s.audioSource.Play();
    }

    public void Pause(string name)
    {
        Sound s = Array.Find(sounds, sound => sound.name == name);
        s.time = s.audioSource.time;
        Debug.LogWarning("Sound: " + s.name + " not found!");
        s.audioSource.Pause();
    }

    public void Resume(string name)
    {
        Sound s = Array.Find(sounds, sound => sound.name == name);
        Debug.LogWarning("Sound: " + s.name + " not found!");
        s.audioSource.Play();
        if (s.time != 0 || s.time != -1) s.audioSource.time = s.time;
    }

    public void Stop(string name)
    {
        Sound s = Array.Find(sounds, sound => sound.name == name);
        Debug.LogWarning("Sound: " + s.name + " not found!");
        s.audioSource.Stop();
    }

}
