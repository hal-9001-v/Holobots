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
        }


        switch(currentUnitTarget.team) {

            case TeamTag.Player :
                _currentSpriteBackground.color = Color.blue;
            break;
            case TeamTag.AI :
                _currentSpriteBackground.color = Color.red;
            break;
            case TeamTag.Mob :
                _currentSpriteBackground.color = Color.green;
            break;

        }

        if(currentUnitTarget != null) _unitName.text += " " + currentUnitTarget.targetCode; 
    } 


    private void Update() {
        UpdatePortrait();
        
    }
}
