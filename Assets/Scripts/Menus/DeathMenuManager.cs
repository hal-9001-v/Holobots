using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.SceneManagement;
public class DeathMenuManager : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Button _quit;
    [SerializeField] private Button _return;

    [SerializeField] TextMeshProUGUI _titleMesh;
    [Space(5)]

    [SerializeField] TextMeshProUGUI _killsPlayerOneMesh;
    [SerializeField] TextMeshProUGUI _deathPlayerOneMesh;

    [Space(5)]

    [SerializeField] TextMeshProUGUI _deathPlayerTwoMesh;
    [SerializeField] TextMeshProUGUI _killsPlayerTwoMesh;
    [SerializeField] TextMeshProUGUI _turnsMesh;

    [SerializeField] Sprite goodStar;
    [SerializeField] Sprite badStar;

    [SerializeField] Image[] stars;
    [SerializeField] Image[] miniatureBackgrounds;
    

 
    TextMeshProUGUI pointText;
    TextMeshProUGUI turnText;

    Sprite[] starSprites = new Sprite[4];
    SpriteRenderer pointRenderer;

    private LevelLoader _levelLoader;

    private int _killsOne;
    private int _deathsOne;

    private int _killsTwo;
    private int _deathsTwo;

    private int _turns;

    Animator _animator;

    const string AnimationStartTrigger = "Start";

    public int turns
    {
        get
        {
            return _turns;
        }
    }

    private void Awake()
    {
        _levelLoader = FindObjectOfType<LevelLoader>();

        _animator = GetComponent<Animator>();

        _quit.onClick.AddListener(() =>
        {
            Application.Quit();
        });
             _return.onClick.AddListener(() =>
        {
            SceneManager.LoadScene(0, LoadSceneMode.Single);
        });

    }

    void UpdatePointsGUI(TeamTag winner)
    {
        switch (winner)
        {
            case TeamTag.Player1:
                _titleMesh.text = "Player One Won!";
                break;

            case TeamTag.Player2:
                _titleMesh.text = "Player Two Won!";
                break;

            case TeamTag.AI:
                _titleMesh.text = "Team AI 1 Won!";
                break;

            case TeamTag.AI2:
                _titleMesh.text = "Team AI 2 Won!";
                break;

            case TeamTag.Mob:
                _titleMesh.text = "Mobs Won!";
                break;

            default:
                _titleMesh.text = "Defeat!";
                break;
        }

        _killsPlayerOneMesh.text =  _killsOne.ToString();
        _killsPlayerTwoMesh.text = "Kills: " + _killsTwo.ToString();

        _deathPlayerOneMesh.text =  _deathsOne.ToString();
        _deathPlayerTwoMesh.text = _deathsTwo.ToString();

        _turnsMesh.text =  _turns.ToString();

       Color color;
        switch (winner)
        {

           case TeamTag.Player1:
                  ColorUtility.TryParseHtmlString("#14f7ff", out color );
                break;
            case TeamTag.AI:
                ColorUtility.TryParseHtmlString("#ff1c14", out color );
                   break;
            case TeamTag.Mob:
                ColorUtility.TryParseHtmlString("#18ff14", out color );
                  break;
            case TeamTag.AI2:
                ColorUtility.TryParseHtmlString("#c114ff", out color );
                   break;

            default:
                ColorUtility.TryParseHtmlString("#14f7ff", out color );
            break;

        }

        miniatureBackgrounds[0].color = color;
        miniatureBackgrounds[1].color =color;   

        int starsInt = 0;
        if(turns < 10) {

            starsInt = 5;

        } else if (turns < 20){

            starsInt = 4;

        } else if(turns < 30){

            starsInt = 3;

        }
        else if(turns < 40){

            starsInt = 2;

        }
        else if (turns < 50){
            starsInt = 1;
        } 

        for(int i = 0; i < starsInt; i++){

            stars[i].sprite = goodStar;

        }
    }

    public void DisplayEndgameScreen(TeamTag winner)
    {
        UpdatePointsGUI(winner);

        _animator.SetTrigger(AnimationStartTrigger);

    }

    public void AddTurn()
    {
        _turns++;
    }

    public void AddKill(TeamTag tag)
    {
        switch (tag)
        {
            case TeamTag.Player1:
                _killsOne++;
                break;
            case TeamTag.Player2:
                _killsTwo++;
                break;
            default:
                break;
        }
    }

    public void AddDeath(TeamTag tag)
    {
        switch (tag)
        {
            case TeamTag.Player1:
                _deathsOne++;
                break;

            case TeamTag.Player2:
                _deathsTwo++;
                break;

            default:
                break;
        }
    }

}