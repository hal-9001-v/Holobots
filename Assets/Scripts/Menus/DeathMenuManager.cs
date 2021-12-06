using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class DeathMenuManager : MonoBehaviour
{

    private LevelLoader _levelLoader;
    [SerializeField] private Button _returnToMenu;
    [SerializeField] private Button _continue;
    [SerializeField] private Button _quit;

    Sprite[] starSprites = new Sprite[4];
    SpriteRenderer pointRenderer;
    TextMeshProUGUI pointText;
    TextMeshProUGUI turnText;
    private int _points;
    private int _turns;
    public int turns{
         get{
             return _turns;
         }
         set{
            _turns =turns;  
         }
     }

    private void Awake() {
        _levelLoader = FindObjectOfType<LevelLoader>();

            _continue.onClick.AddListener(() =>
        {
            Continue();
        });
    
        _quit.onClick.AddListener(() =>
        {
            Application.Quit();
        });
       _returnToMenu.onClick.AddListener(() =>
        {
            ReturnToMenu();
        });
    }
    

    private void Continue(){

        if(_points > 0) {

            NextLevel();

        } else RestartLevel();
        
    }
    private void NextLevel(){}

    private void RestartLevel(){}

    
    private void ReturnToMenu(){
       
        Time.timeScale = 1f;
        _levelLoader.LoadLevel(0);



    }

    public void UpdatePointsGUI(){


        switch(_points){

            case 0:
                pointRenderer.sprite = starSprites[0];
                turnText.text = "You lost! And it took you " + turns + " LMAO";
                pointText.text = "0 Stars, what a loser!";
                break;
            case 1:
                pointRenderer.sprite = starSprites[1];
                turnText.text = "You Won! But it took you " + turns + " a bit slow, isn't it?";
                pointText.text = "1 Stars, You can do better!";
                break;
            case 2:
                pointRenderer.sprite = starSprites[2];
                turnText.text = "You Won! And it took you " + turns + " Not THAT impressive, ain't it?";
                pointText.text = "2 Stars, Almost there!";
                break;
            case 3:
                pointRenderer.sprite = starSprites[3];
                turnText.text = "You Won! And it only took you " + turns + " Just. Wow.";
                pointText.text = "3 Stars, Perfect! Incredible!";
                break;

        }


    }

}

