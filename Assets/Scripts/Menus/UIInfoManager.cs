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

    private SpriteRenderer _currentSprite;
    public SpriteRenderer currentSprite{
            get{
                return _currentSprite;
            }
            set{
                _currentSprite = currentSprite;  
            }
        }

    public void UpdatePortrait(){

        switch(currentUnit){

            case UnitTypes.Fighter:
                _unitName.text = "Fighter";
                
            break;

            case UnitTypes.Healer:
                _unitName.text = "Healer";

            break;

            case UnitTypes.Tank:
                _unitName.text = "Tank";

            break;
        
            case UnitTypes.Ranger:
                _unitName.text = "Ranger";

            break;
            case UnitTypes.Rogue:
                _unitName.text = "Rogue";

            break;
        }
    } 



}
