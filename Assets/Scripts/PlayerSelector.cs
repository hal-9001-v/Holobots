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
        units = new List<PlayerUnit>();

        _inputContainer = FindObjectOfType<InputMapContainer>();
        _cameraMovement = FindObjectOfType<CameraMovement>();

        _gameDirector = FindObjectOfType<GameDirector>();
    }
    // Start is called before the first frame update
    void Start()
    {
        UpdateUnits();

        _inputContainer.inputMap.Game.ResetStepsOnSelectedUnit.performed += ctx =>
        {
            ResetStepsOnUnit();
        };

        _inputContainer.inputMap.Game.NextUnit.performed += ctx =>
        {
            SelectNextUnit();
        };

        _inputContainer.inputMap.Game.ExecuteSteps.performed += ctx =>
        {
            _gameDirector.ExecuteSteps();
        };
    }

    void SelectNextUnit()
    {
        SelectUnit(_unitIndex + 1);
    }

    void SelectUnit(int index)
    {
        if (_isTurnActive)
        {
            units[_unitIndex].DisableControl();

            _unitIndex = index;

            if (_unitIndex >= units.Count)
            {
                _unitIndex = 0;
            }
            else if (_unitIndex < 0)
            {
                _unitIndex = units.Count;
            }

            units[_unitIndex].EnableControl();

            _cameraMovement.LookAt(units[_unitIndex].transform.position);
        }
    }

    void ResetStepsOnUnit()
    {
        if (_isTurnActive)
        {
            units[_unitIndex].ResetAdapters();
        }
    }

    public void EnableControl()
    {
        _isTurnActive = true;

        UpdateUnits();

        SelectUnit(0);

        foreach (var unit in units)
        {
            unit.ResetAdapters();
        }
    }

    public void DisableControl()
    {
        _isTurnActive = false;

        units[_unitIndex].DisableControl();

    }

    void UpdateUnits()
    {
        units.Clear();

        foreach (PlayerUnit unit in FindObjectsOfType<PlayerUnit>())
        {
            if (!unit.isDead)
            {
                units.Add(unit);
            }
        }

        if (units.Count != 0)
        {
            _cameraMovement.LookAt(units[0].transform.position);
        }


    }
}
