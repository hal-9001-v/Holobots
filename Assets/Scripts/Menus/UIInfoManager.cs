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

    public Target currentUnitTarget;

    [SerializeField] private Image _currentSprite;
    [SerializeField] private Image _currentSpriteBackground;
    Target target;

    private void Start() {
        target = FindObjectOfType<Target>();
    }

   
    public void UpdatePortrait(){

        switch(currentUnitTarget.targetType){

            case TargetType.Fighter:
                _unitName.text = "F1GHT3R" + currentUnitTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[0];
            break;

            case TargetType.Healer:
                _unitName.text = "H34L3R" + currentUnitTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[1];

            break;

            case TargetType.Ranger:
                _unitName.text = "R4NG3R" + currentUnitTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[2];

            break;
        
            case TargetType.Rogue:
                _unitName.text = "R0G3" + currentUnitTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[3];

            break;
            case TargetType.Tank:
                _unitName.text = "T4Nk" + currentUnitTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[4];

            break;
            case TargetType.Kamikaze:
                _unitName.text = "K4M1K4Z3" + currentUnitTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[5];

            break;
            case TargetType.Turret:
                _unitName.text = "TURR3T" + currentUnitTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[6];

            break;
        }


        switch(currentUnitTarget.teamTag) {

            case TeamTag.Player :
                _currentSpriteBackground.color = Color.blue;
            break;
            case TeamTag.AI :
                _currentSpriteBackground.color = Color.red;
            break;
            case TeamTag.Mob :
                _currentSpriteBackground.color = Color.green;
                break;
            case TeamTag.AI2:
                _currentSpriteBackground.color = Color.gray;
            break;

        }

    } 


    private void Update() {
        UpdatePortrait();
        
    }
}
