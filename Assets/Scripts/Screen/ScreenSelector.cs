using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.EventSystems;
using UnityEngine.UI;
[RequireComponent(typeof(Camera))]
public class ScreenSelector : MonoBehaviour
{
    Camera _camera;

    [Header("Settings")]
    [SerializeField] [Range(1, 100)] float _range;

    Selectable _selectedObject;

    public Action<Selectable> onLeftClickCallback;
    public Action<Selectable> onRightClickCallback;
    public Action<Selectable> onSelectionCallback;
    public Action onNothingSelectedCallback;

    InputMapContainer inputMapContainer;
    [SerializeField]Button confirm;
    private void Awake()
    {
        _camera = GetComponent<Camera>();
    }

    private void Start() {
        inputMapContainer = FindObjectOfType<InputMapContainer>();  
         confirm.onClick.AddListener(() =>
        {
            ConfirmTouch();
        });
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;
        Ray selectionRay;
        if(SystemInfo.deviceType == DeviceType.Handheld && Input.touchCount > 0){ 
        
                Touch t;
                t = Input.GetTouch(0);
                selectionRay= _camera.ScreenPointToRay(t.position);

            if (Physics.Raycast(selectionRay, out hit, _range) && t.phase == UnityEngine.TouchPhase.Began)
            {
                if(!EventSystem.current.IsPointerOverGameObject(t.fingerId)){
                    if (_selectedObject == null || _selectedObject.gameObject != hit.collider.gameObject )
                    {
                        TryToSelectTouch(hit.collider.gameObject,t);
                    }
                }
            
            } 
            else if(t.phase == UnityEngine.TouchPhase.Canceled)
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

        else if(SystemInfo.deviceType == DeviceType.Desktop){ 
         
            selectionRay = _camera.ScreenPointToRay(Mouse.current.position.ReadValue());
            if (Physics.Raycast(selectionRay, out hit, _range))
            {
                if(!EventSystem.current.IsPointerOverGameObject()){
                    if (_selectedObject == null || _selectedObject.gameObject != hit.collider.gameObject)
                    {
                        TryToSelect(hit.collider.gameObject);
                    }

                    CheckClick();
                }
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
    bool TryToSelectTouch(GameObject objectForSelection, Touch t)
    {
        if (_selectedObject)
            _selectedObject.Deselect();

        _selectedObject = objectForSelection.GetComponent<Selectable>();

        if (_selectedObject)
        {
            _selectedObject.Select();

            if (onSelectionCallback != null &&  !EventSystem.current.IsPointerOverGameObject(t.fingerId))
            {
                FindObjectOfType<AudioManager>().Play("TestSelect");
                onSelectionCallback.Invoke(_selectedObject);
                   
            }

        }

        return _selectedObject != null;
    }

    public void CheckClick()
    {   
   
      if(SystemInfo.deviceType == DeviceType.Desktop || SystemInfo.deviceType == DeviceType.Unknown){
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

    public void ConfirmTouch(){

        if(_selectedObject != null){   
            _selectedObject.Click();
            
            if (onLeftClickCallback != null)
                onLeftClickCallback.Invoke(_selectedObject);
            if (onRightClickCallback != null)
            onRightClickCallback.Invoke(_selectedObject);
        }
    }

            
}
