using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class UIInfoManager : MonoBehaviour
{
    [Header("References")]
    [SerializeField] TextMeshProUGUI _unitName;
    [SerializeField] Image _currentSprite;
    [SerializeField] Image _currentSpriteBackground;
    [SerializeField] Sprite[] _portraitSprites;
    
    public TextMeshProUGUI unitName
    {
        get
        {
            return _unitName;
        }
        set
        {
            _unitName = unitName;
        }
    }

    public Target currentTarget { get; private set; }

    public void SetTargetUnit(Target target)
    {
        currentTarget = target;
        switch (currentTarget.targetType)
        {
            case TargetType.Fighter:
                _unitName.text = "F1GHT3R" + currentTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[0];
                break;

            case TargetType.Healer:
                _unitName.text = "H34L3R" + currentTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[1];

                break;

            case TargetType.Ranger:
                _unitName.text = "R4NG3R" + currentTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[2];

                break;

            case TargetType.Rogue:
                _unitName.text = "R0G3" + currentTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[3];

                break;
            case TargetType.Tank:
                _unitName.text = "T4Nk" + currentTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[4];

                break;
            case TargetType.Kamikaze:
                _unitName.text = "K4M1K4Z3" + currentTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[5];

                break;
            case TargetType.Turret:
                _unitName.text = "TURR3T" + currentTarget.targetCode;
                _currentSprite.sprite = _portraitSprites[6];

                break;
        }


        Color color;
        switch (currentTarget.teamTag)
        {
            case TeamTag.Player1:
                  ColorUtility.TryParseHtmlString("#14f7ff", out color );
                break;
                case TeamTag.Player2:
                  ColorUtility.TryParseHtmlString("#ff14c3", out color );
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
        _currentSpriteBackground.color = color;                


    }
}
