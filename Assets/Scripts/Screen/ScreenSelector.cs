using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.EventSystems;

[RequireComponent(typeof(Camera))]
public class ScreenSelector : MonoBehaviour
{
    Camera _camera;

    [Header("Settings")]
    [SerializeField] [Range(1, 100)] float _range;
    [SerializeField] LayerMask _selectableMask;

    Selectable _selectedObject;

    public Action<Selectable> onLeftClickCallback;
    public Action<Selectable> onRightClickCallback;
    public Action<Selectable> onSelectionCallback;
    public Action onNothingSelectedCallback;

    private void Awake()
    {
        _camera = GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;
        Ray selectionRay = _camera.ScreenPointToRay(Mouse.current.position.ReadValue());

        if (Physics.Raycast(selectionRay, out hit, _range, _selectableMask))
        {
            if (_selectedObject == null || _selectedObject.gameObject != hit.collider.gameObject)
            {
                TryToSelect(hit.collider.gameObject);
            }

            CheckClick();
        }
        else
        {
            if (_selectedObject)
            {
                _selectedObject.Deselect();

                _selectedObject = null;

                if (onNothingSelectedCallback != null)
                {
                    onNothingSelectedCallback.Invoke();
                }
            }
        }


    }

    bool TryToSelect(GameObject objectForSelection)
    {
        if (_selectedObject)
            _selectedObject.Deselect();

        _selectedObject = objectForSelection.GetComponent<Selectable>();

        if (_selectedObject)
        {
            _selectedObject.Select();

            if (onSelectionCallback != null &&  !EventSystem.current.IsPointerOverGameObject())
            {
                FindObjectOfType<AudioManager>().Play("TestSelect");
                onSelectionCallback.Invoke(_selectedObject);
            }

        }

        return _selectedObject != null;
    }

    public void CheckClick()
    {
        if (Mouse.current.press.wasReleasedThisFrame && !EventSystem.current.IsPointerOverGameObject()) 
        {
            if (_selectedObject != null)
            {
                _selectedObject.Click();
                
                if (onLeftClickCallback != null)
                    onLeftClickCallback.Invoke(_selectedObject);
            }
        }

        if (Mouse.current.rightButton.wasReleasedThisFrame && !EventSystem.current.IsPointerOverGameObject())
        {
            if (_selectedObject != null)
            {
                if (onRightClickCallback != null)
                    onRightClickCallback.Invoke(_selectedObject);
            }
        }
    }
}
