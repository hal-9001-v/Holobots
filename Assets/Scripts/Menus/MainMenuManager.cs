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
    [SerializeField] private Button _tutorialButton;

    [SerializeField] private Button _controlsButton;
    [SerializeField] private Button _controlsCloseButton;

    [SerializeField] private Animator _menuAnimator;
    [SerializeField] private Animator _settingsAnimator;

    [SerializeField] private CanvasGroup tutorialCanvasGroup;
    [SerializeField] private CanvasGroup controlsCanvasGroup;

    AudioManager musicPlayer;
void Awake()
{
    if (SystemInfo.deviceType == DeviceType.Handheld){

        _controlsButton.enabled = false;

    }
    musicPlayer = FindObjectOfType<AudioManager>();
    CloseControls();
}
    private void Start()
    {
        _levelLoader = FindObjectOfType<LevelLoader>();

        _playLevelOneButton.onClick.AddListener(() =>
        {
            Play(1);
            musicPlayer.Play("Level1");
        });

        _playLevelTwoButton.onClick.AddListener(() =>
        {
            Play(2);
            musicPlayer.Play("Level2");
        });


        _playPVPButton.onClick.AddListener(() =>
        {
            Play(3);
            musicPlayer.Play("TestMusic");
        });

        _settingsButton.onClick.AddListener(() =>
        {

            DisplaySettings();

        });
        _quitButton.onClick.AddListener(() =>
        {
            Application.Quit();
        });
          _tutorialButton.onClick.AddListener(() =>
        {
            ShowTutorial();
        });
          _controlsButton.onClick.AddListener(() =>
        {
            ShowControls();
        });
        _controlsCloseButton.onClick.AddListener(()=> {

            CloseControls();

        });
    }

    private void ShowControls(){

        controlsCanvasGroup.alpha = 1;
        controlsCanvasGroup.blocksRaycasts = true;

    }
    private void CloseControls(){

        controlsCanvasGroup.alpha = 0;
        controlsCanvasGroup.blocksRaycasts = false;

    }
    private void ShowTutorial(){

        Debug.Log("Tutorial");

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
