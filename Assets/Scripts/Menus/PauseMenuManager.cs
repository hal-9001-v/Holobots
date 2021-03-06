using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class PauseMenuManager : MonoBehaviour
{
    
    private LevelLoader _levelLoader;
    [SerializeField] private Button _returnToMenu;
    [SerializeField] private Button _resume;
    [SerializeField] private Button _settings;
    [SerializeField] private Button _quit;
    [SerializeField] private Button _pauseButton;

    [SerializeField] private SettingsMenuManager _settingsManager;



    private void Awake() {

        LanguageContext lngCtx = FindObjectOfType<LanguageContext>();
        lngCtx.ChangeLanguage(lngCtx.currentLanguage);
        _levelLoader = FindObjectOfType<LevelLoader>();

          if(_resume!= null)  _resume.onClick.AddListener(() =>
        {
            Resume();
        });
      if(_settings != null)  _settings.onClick.AddListener(() =>
        {
          
            DisplaySettings();
          
        });
        if(_quit != null) _quit.onClick.AddListener(() =>
        {
            Application.Quit();
        });
        if(_returnToMenu != null) _returnToMenu.onClick.AddListener(() =>
        {
            ReturnToMenu();
            AudioManager audio = FindObjectOfType<AudioManager>();
            audio.Play("Menu");
            audio.Stop("Level1");   
            audio.Stop("Level2");   
            audio.Stop("TestMusic");   
        });
    }
    

    private void Resume(){

        StartCoroutine(ResumeC());
        Time.timeScale = 0.75f;
       _pauseButton.GetComponent<CanvasGroup>().alpha = 1;
    }

    private IEnumerator ResumeC(){

        GetComponent<Animator>().SetTrigger("End");
        yield return new WaitForSeconds(1f);
        GetComponent<Animator>().ResetTrigger("End");

    }
    private void DisplaySettings(){

        StartCoroutine(DisplaySettingsC());

    }
    private IEnumerator DisplaySettingsC(){

        _settingsManager = FindObjectOfType<SettingsMenuManager>();
        _settingsManager.GetComponentInChildren<Animator>().SetTrigger("Start");
        yield return new WaitForSeconds(1f);
        _settingsManager.GetComponentInChildren<Animator>().ResetTrigger("Start");
    
    }
    
    private void ReturnToMenu(){
       
        Time.timeScale = 0.75f;
        _levelLoader.LoadLevel(0);



    }

    

}
