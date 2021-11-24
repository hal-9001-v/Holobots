using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeleerPlayerAdapter : Adapter, ISelectorObserver
{

    Meleer _meleer;
    Target _target;

    Ground _ground;

    GroundTile _selectedTile;

    public MeleerPlayerAdapter(Meleer meleer, Target target) : base(AdapterType.Meleer)
    {
        _meleer = meleer;
        _target = target;

        _ground = GameObject.FindObjectOfType<Ground>();

        SetNotifications();
    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;


        if (_selectedTile)
        {
            _meleer.SetHit(_selectedTile);
        }
    }

    public void OnNothingSelectNotify()
    {
        if (!_inputIsActive) return;

        _selectedTile = null;
        _meleer.Hide();
    }

    public void OnRightClickNotify(Selectable selectable)
    {
        throw new System.NotImplementedException();
    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        var tile = selectable.GetComponent<GroundTile>();


        if (_selectedTile == null || _selectedTile != tile)
        {
            if (_ground.GetTilesInRange(_target.currentGroundTile, 2).Contains(tile))
            {
                _meleer.SetPlanningHit(tile);

                _selectedTile = tile;
            }
            else
            {
                _selectedTile = null;
            }
        }
    }

    public override void OnStartControl()
    {
        
    }

    public override void OnStopControl()
    {
        _meleer.Hide();
        _selectedTile = null;
    }

    public override void Reset()
    {
        
    }

    public void SetNotifications()
    {
        var screenSelector = GameObject.FindObjectOfType<ScreenSelector>();

        screenSelector.onLeftClickCallback += OnLeftClickNotify;
        screenSelector.onSelectionCallback += OnSelectNotify;
        screenSelector.onNothingSelectedCallback += OnNothingSelectNotify;
    }
}
