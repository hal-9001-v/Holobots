using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerSelector : MonoBehaviour
{
    public List<PlayerUnit> units;

    InputMapContainer _inputContainer;

    CameraMovement _cameraMovement;

    public Action<Selectable> onSelectionCallback;

    public Action<Selectable> onLeftClickCallback;
    public Action<Selectable> onRightClickCallback;

    int _unitIndex;
    bool _isTurnActive;

    GameDirector _gameDirector;

    private void Awake()
    {

    }
 

}
