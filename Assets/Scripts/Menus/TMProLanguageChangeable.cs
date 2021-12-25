using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

[RequireComponent(typeof(TextMeshProUGUI))]
public class TMProLanguageChangeable : LanguageChangeable
{
    [Header("Settings")]
    [SerializeField] bool _applyDifferentSize;

    [TextArea(1, 3)]
    [SerializeField] string _englishText;
    [SerializeField] int _englishSize = 10;
    [TextArea(1, 3)]
    [SerializeField] string _spanishText;
    [SerializeField] int _spanishSize = 10;


    TextMeshProUGUI _textMesh;

    void Awake()
    {
        _textMesh = GetComponent<TextMeshProUGUI>();
    }

    private void Start()
    {

    }

    public override void ChangeLanguage(Language language)
    {
        switch (language)
        {
            case Language.English:
                _textMesh.text = _englishText;

                if (_applyDifferentSize)
                    _textMesh.fontSize = _englishSize;
                break;
            case Language.Spanish:
                _textMesh.text = _spanishText;

                if (_applyDifferentSize)
                    _textMesh.fontSize = _spanishSize;
                break;
            default:
                break;
        }


    }

    [ContextMenu("Set Text from editor")]
    void SetText()
    {
        if (!_textMesh) _textMesh = GetComponent<TextMeshProUGUI>();

        ChangeLanguage(Language.English);
    }
}
