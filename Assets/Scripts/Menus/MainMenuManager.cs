using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class MainMenuManager : MonoBehaviour
{
    private LevelLoader _levelLoader;
    [SerializeField] private Button _playLevelOneButton;
    [SerializeField] private Button _playLevelTwoButton;
    [SerializeField] private Button _playPVPButton;
    [SerializeField] private Button _settingsButton;
    [SerializeField] private Button _quitButton;

    [SerializeField] private Animator _menuAnimator;
    [SerializeField] private Animator _settingsAnimator;

    private void Start()
    {
        _levelLoader = FindObjectOfType<LevelLoader>();

        _playLevelOneButton.onClick.AddListener(() =>
        {
            Play(1);
        });

        _playLevelTwoButton.onClick.AddListener(() =>
        {
            Play(2);
        });


        _playPVPButton.onClick.AddListener(() =>
        {
            Play(3);
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

    private void Play(int level)
    {

        _levelLoader.LoadLevel(level);

    }


    private void DisplaySettings()
    {


        StartCoroutine(DisplaySettingsC());

    }

    private IEnumerator DisplaySettingsC()
    {

        _menuAnimator.SetTrigger("End");
        _settingsAnimator.SetTrigger("Start");


        yield return new WaitForSeconds(1f);

        _settingsAnimator.ResetTrigger("Start");
        _menuAnimator.ResetTrigger("End");
    }
}
