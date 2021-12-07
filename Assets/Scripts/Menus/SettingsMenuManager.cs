using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;
public class SettingsMenuManager : MonoBehaviour
{

    private SettingsMenuManager[] _settingsMenu;
    [SerializeField] private Button _menu;
    [SerializeField] private Slider _SFX;
    [SerializeField] private Slider _music;

    private Animator _settingsAnimator;
    private Animator _mainMenuAnimator;
    private void Awake() {

    
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
