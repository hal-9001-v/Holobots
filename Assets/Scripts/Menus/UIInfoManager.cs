using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class UIInfoManager : MonoBehaviour
{   

    public enum UnitTypes{

        Fighter,
        Healer,
        Ranger,
        Rogue,
        Tank,

    }
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

    public UnitTypes currentUnit;

    [SerializeField] private Image _currentSprite;
 
    public void UpdatePortrait(){

        switch(currentUnit){

            case UnitTypes.Fighter:
                _unitName.text = "Fighter";
                _currentSprite.sprite = _portraitSprites[0];
            break;

            case UnitTypes.Healer:
                _unitName.text = "Healer";
                _currentSprite.sprite = _portraitSprites[1];

            break;

            case UnitTypes.Ranger:
                _unitName.text = "Ranger";
                _currentSprite.sprite = _portraitSprites[2];

            break;
        
            case UnitTypes.Rogue:
                _unitName.text = "Rogue";
                _currentSprite.sprite = _portraitSprites[3];

            break;
            case UnitTypes.Tank:
                _unitName.text = "Tank";
                _currentSprite.sprite = _portraitSprites[4];

            break;
        }
    } 


    private void Update() {
        UpdatePortrait();
    }
}
