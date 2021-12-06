using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class UIInfoManager : MonoBehaviour
{   


    [SerializeField] private TextMeshProUGUI _unitName;
    public TextMeshProUGUI unitName{
         get{
             return _unitName;
         }
         set{
            _unitName =unitName;  
         }
     }

    [SerializeField] private Sprite[] _portraitSprites;

    public TargetType currentUnit;

    [SerializeField] private Image _currentSprite;
 
    public void UpdatePortrait(){

        /*switch(currentUnit){

            case TargetType.Fighter:
                _unitName.text = "Fighter";
                _currentSprite.sprite = _portraitSprites[0];
            break;

            case TargetType.Healer:
                _unitName.text = "Healer";
                _currentSprite.sprite = _portraitSprites[1];

            break;

            case TargetType.Ranger:
                _unitName.text = "Ranger";
                _currentSprite.sprite = _portraitSprites[2];

            break;
        
            case TargetType.Rogue:
                _unitName.text = "Rogue";
                _currentSprite.sprite = _portraitSprites[3];

            break;
            case TargetType.Tank:
                _unitName.text = "Tank";
                _currentSprite.sprite = _portraitSprites[4];

            break;
        }*/
    } 


    private void Update() {
        UpdatePortrait();
    }
}
