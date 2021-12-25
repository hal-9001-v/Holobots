using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;
using UnityEngine.Events;

using UnityEngine.Audio;

public class SettingsMenuManager : MonoBehaviour
{
    [Header("References")]
    [SerializeField] AudioMixer _audioMixer;

    [Header("Sliders")]

    [SerializeField] private Slider _SFX;
    [SerializeField] private Slider _master;
    [SerializeField] private Slider _music;

    [Header("Buttons")]
    [SerializeField] private Button _menu;



    [Header("Languages")]
    [SerializeField] Button _englishButton;
    [SerializeField] Button _spanishButton;

    
    const string MasterAudioKey = "Master";
    const string MusicAudioKey = "Music";
    const string SFXAudioKey = "SFX";

    
    LanguageContext _languageContext;

    const float MaxAudioValue = 1f;
    const float MinAudioValue = 0.001f;


    private Animator _settingsAnimator;
    private Animator _mainMenuAnimator;

    private SettingsMenuManager[] _settingsMenu;

    private void Awake() {
            
            _languageContext = FindObjectOfType<LanguageContext>();

            _menu.onClick.AddListener(() =>
            {
                ReturnToMenu();
            });
            _settingsAnimator = GetComponentInChildren<Animator>();

            _menu.onClick.AddListener(() =>
            {
                ReturnToMenu();
            });
            _settingsAnimator = GetComponentInChildren<Animator>();
        
        _englishButton.onClick.AddListener(() =>
            {
                SetLanguage(Language.English);
            });

            _spanishButton.onClick.AddListener(() =>
            {
                SetLanguage(Language.Spanish);
            });

            SetSliders();
    }

      public void SetSliders()
    {
        SetSlider(_master, SetMasterVolume, MasterAudioKey);
        SetSlider(_music, SetMusicVolume, MusicAudioKey);
        SetSlider(_SFX, SetSFXVolume, SFXAudioKey);
    }

    void SetSlider(Slider slider, UnityAction<float> onValueChanged, string groupKey)
    {
        slider.onValueChanged.AddListener(onValueChanged);

        slider.minValue = MinAudioValue;
        slider.maxValue = MaxAudioValue;
        float value;
        _audioMixer.GetFloat(groupKey, out value);
        value = Mathf.Pow(10,value/20);
        slider.value = value;
    }
      public void SetMasterVolume(float newVolume)
    {
        _audioMixer.SetFloat(MasterAudioKey, Mathf.Log10(newVolume)*20);
    }

    public void SetMusicVolume(float newVolume)
    {
        _audioMixer.SetFloat(MusicAudioKey, Mathf.Log10(newVolume)*20);
    }

    public void SetSFXVolume(float newVolume)
    {
        _audioMixer.SetFloat(SFXAudioKey, Mathf.Log10(newVolume)*20);
    }

   public void SetLanguage(Language language)
    {
        switch (language)
        {
            case Language.English:
                Debug.Log("English!");
                _languageContext.ChangeLanguage(Language.English);

                break;
            case Language.Spanish:
                Debug.Log("Spanish!");
                _languageContext.ChangeLanguage(Language.Spanish);

                break;
        }
    }

    public void ReturnToMenu(){

        Debug.Log("Trying to return");
        if(SceneManager.GetActiveScene().buildIndex == 0) {

            StartCoroutine(ReturnToMenuC(true));
            Debug.Log("Return to main menu");

        } else {
            Time.timeScale = 1f;
            StartCoroutine(ReturnToMenuC(false));
            Debug.Log("Return to pause menu");
            
        }

    }

    private IEnumerator ReturnToMenuC(bool b){

        if(b){
            _mainMenuAnimator = FindObjectOfType<MainMenuManager>().GetComponentInChildren<Animator>();

            if(_mainMenuAnimator != null) {
                _mainMenuAnimator.SetTrigger("Start");
                _settingsAnimator.SetTrigger("End");
                yield return new WaitForSeconds(2.0f);

                _mainMenuAnimator.ResetTrigger("Start");
                _settingsAnimator.ResetTrigger("End");
                
            }
        } else if (!b){
            
            Animator _pauseAnimator = FindObjectOfType<PauseMenuManager>().GetComponentInChildren<Animator>();
            if(_pauseAnimator!=null){
                _pauseAnimator.SetTrigger("Start");
                _settingsAnimator.SetTrigger("End");
                yield return new WaitForSeconds(0.1f);
                _pauseAnimator.ResetTrigger("Start");
                yield return new WaitForSeconds(1.9f);
                _settingsAnimator.ResetTrigger("End");
            }
        }

        

    }
    
}
