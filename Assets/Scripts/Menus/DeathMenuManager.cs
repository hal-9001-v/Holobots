using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.SceneManagement;
public class DeathMenuManager : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Button _quit;

    [SerializeField] TextMeshProUGUI _titleMesh;
    [Space(5)]

    [SerializeField] TextMeshProUGUI _killsPlayerOneMesh;
    [SerializeField] TextMeshProUGUI _deathPlayerOneMesh;

    [Space(5)]

    [SerializeField] TextMeshProUGUI _deathPlayerTwoMesh;
    [SerializeField] TextMeshProUGUI _killsPlayerTwoMesh;
    [SerializeField] TextMeshProUGUI _turnsMesh;

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

        _killsPlayerOneMesh.text = "Kills: " + _killsOne.ToString();
        _killsPlayerTwoMesh.text = "Kills: " + _killsTwo.ToString();

        _deathPlayerOneMesh.text = "Deaths: " + _deathsOne.ToString();
        _deathPlayerTwoMesh.text = "Deaths: " + _deathsTwo.ToString();

        _turnsMesh.text = "Turns: " + _turns.ToString();
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

