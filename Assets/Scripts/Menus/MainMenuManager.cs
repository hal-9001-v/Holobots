using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class MainMenuManager : MonoBehaviour
{
    private LevelLoader _levelLoader;
    [SerializeField] private Button _playButton;
    [SerializeField] private Button _settingsButton;
    [SerializeField] private Button _quitButton;

   [SerializeField] private Animator _menuAnimator;
   [SerializeField] private Animator _settingsAnimator;
    
    private void Awake() {
        
        _levelLoader = FindObjectOfType<LevelLoader>();

    }


    private void Start() {
        
        _playButton.onClick.AddListener(() =>
        {
            Play();
        });
        _settingsButton.onClick.AddListener(() =>
        {
          
            DisplaySettings();
          
        });
        _quitButton.onClick.AddListener(() =>
        {
            Application.Quit();
        });
    }
    
    private void Play(){

        _levelLoader.LoadLevel(1);

    }


    private void DisplaySettings(){

        
        StartCoroutine(DisplaySettingsC());

    }

    private IEnumerator DisplaySettingsC(){

        _menuAnimator.SetTrigger("End");
        _settingsAnimator.SetTrigger("Start");


        yield return new WaitForSeconds(1f);

        _settingsAnimator.ResetTrigger("Start");
        _menuAnimator.ResetTrigger("End");
    }
}
