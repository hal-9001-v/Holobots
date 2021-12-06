using System;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(CanvasGroup))]
public class SkillHolder : MonoBehaviour
{
    [Header("References")]
    [SerializeField] Image _image;
    [Tooltip("This image will be highlighted when this skill is selected")]
    [SerializeField] RawImage _highlightedImage;
    [SerializeField] Button _button;

    [Header("Settings")]
    [SerializeField] AdapterIcon[] _icons;
    [SerializeField] Color _selectedColor;
    [SerializeField] Color _unselectedColor;

    CanvasGroup _canvasGroup;

    //Adapter represented by this holder
    Adapter _currentAdapter;

    SkillSelector _skillSelector;

    private void Awake()
    {
        _canvasGroup = GetComponent<CanvasGroup>();

        _skillSelector = FindObjectOfType<SkillSelector>();

        _button.onClick.AddListener(() =>
        {
            _skillSelector.SetSelectedSkill(this);
        });
    }

    public void SelectSkill()
    {
        if (_currentAdapter != null)
        {
            _currentAdapter.EnableInput();
        }

        _highlightedImage.color = _selectedColor;
    }

    public void DeselectSkill()
    {
        if (_currentAdapter != null)
        {
            _currentAdapter.DisableInput();
        }
        _highlightedImage.color = _unselectedColor;
    }

    public void Show(Adapter adapter)
    {
        _canvasGroup.alpha = 1;
        _canvasGroup.blocksRaycasts = true;

        SetAdapter(adapter);
    }

    public void Hide()
    {
        _canvasGroup.alpha = 0;
        _canvasGroup.blocksRaycasts = false;

        DeselectSkill();

        _currentAdapter = null;
    }

    void SetAdapter(Adapter adapter)
    {
        _currentAdapter = adapter;

        _image.sprite = GetSpriteIcon(_currentAdapter.adapterType);
    }

    Sprite GetSpriteIcon(AdapterType adapterType)
    {
        foreach (var icon in _icons)
        {
            if (icon.adapterType == adapterType)
            {
                return icon.icon;
            }
        }

        Debug.LogWarning("No icon for requested type: " + adapterType.ToString());
        return _icons[0].icon;
    }

    [Serializable]
    struct AdapterIcon
    {
        [SerializeField] public Sprite icon;
        [SerializeField] public AdapterType adapterType;
    }

}
