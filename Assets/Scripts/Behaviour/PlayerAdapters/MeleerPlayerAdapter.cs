using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeleerPlayerAdapter : Adapter, ISelectorObserver
{

    Meleer _meleer;
    Target _target;

    Ground _ground;

    Target _selectedUnit;

    Highlighter _highlighter;

    public MeleerPlayerAdapter(Meleer meleer, Target target) : base(AdapterType.Meleer)
    {
        _meleer = meleer;
        _target = target;

        _highlighter = new Highlighter();

        _ground = GameObject.FindObjectOfType<Ground>();

        SetNotifications();
    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;


        if (_selectedUnit)
        {
            _meleer.Hit(_selectedUnit);
            _highlighter.Unhighlight();
        }
    }

    public void OnNothingSelectNotify()
    {
        if (!_inputIsActive) return;

        _selectedUnit = null;
        _highlighter.Unhighlight();
    }

    public void OnRightClickNotify(Selectable selectable)
    {
        throw new System.NotImplementedException();
    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;
        _highlighter.Unhighlight();

        var unit = selectable.GetComponent<Target>();

        if (unit == null)
        {
            var tile = selectable.GetComponent<GroundTile>();

            if (tile)
            {
                unit = tile.unit;
            }
        }

        if (unit)
        {
            if (unit.team != _target.team)
            {
                if (_ground.GetTilesInRange(_target.currentGroundTile, _meleer.meleeRange).Contains(unit.currentGroundTile))
                {
                    _selectedUnit = unit;

                    _highlighter.AddDangerededHighlightable(unit.highlightable);
                    _highlighter.AddDangerededHighlightable(unit.currentGroundTile.highlightable);
                }
                else
                {
                    _selectedUnit = null;
                    
                }
            }

        
        }
    }

    public override void OnStartControl()
    {

    }

    public override void OnStopControl()
    {
        _selectedUnit = null;

        _highlighter.Unhighlight();
    }


    public void SetNotifications()
    {
        var screenSelector = GameObject.FindObjectOfType<ScreenSelector>();

        screenSelector.onLeftClickCallback += OnLeftClickNotify;
        screenSelector.onSelectionCallback += OnSelectNotify;
        screenSelector.onNothingSelectedCallback += OnNothingSelectNotify;
    }
}
