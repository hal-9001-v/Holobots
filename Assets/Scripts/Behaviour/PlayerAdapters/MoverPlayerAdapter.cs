using System.Collections.Generic;
using UnityEngine;
public class MoverPlayerAdapter : Adapter, ISelectorObserver
{
    //Lines and Path Finding
    GridLine _gridLine;

    Mover _mover;
    Target _target;
    TurnActor _turnActor;

    List<GroundTile> _tempPath;

    public MoverPlayerAdapter(Mover mover, Target target, TurnActor actor) : base(AdapterType.Move)
    {
        _mover = mover;
        _target = target;
        _turnActor = actor;

        _gridLine = GameObject.FindObjectOfType<GridLineProvider>().CloneMovementGridLine(mover.name);

        SetNotifications();
    }

    public void OnRightClickNotify(Selectable selectable)
    {
        if (!_inputIsActive){ 
            return;
        }

        if (_turnActor.currentTurnPoints > 0 && _tempPath != null && _tempPath.Count != 0)
        {
            _mover.MoveInPath(_tempPath);
        }
    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        if (_gridLine)
        {
            var destination = selectable.GetComponent<GroundTile>();

            if (destination)
            {
                _tempPath = _mover.GetFilteredPath(_target.currentGroundTile, destination);

                Vector3[] points = new Vector3[_tempPath.Count];

                for (int i = 0; i < _tempPath.Count; i++)
                {
                    points[i] = _tempPath[i].transform.position;
                }

                _gridLine.SetPoints(points);
            }
        }
    }

    public void SetNotifications()
    {
        var screenSelector = GameObject.FindObjectOfType<ScreenSelector>();

        screenSelector.onRightClickCallback += OnRightClickNotify;
        screenSelector.onSelectionCallback += OnSelectNotify;
        screenSelector.onNothingSelectedCallback += OnNothingSelectNotify;

    }


    public override void OnStartControl()
    {
        //Nothing!

    }


    public override void OnStopControl()
    {
        if (_tempPath != null)
        {
            _tempPath.Clear();
        }
        _gridLine.HideLine();
    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        throw new System.NotImplementedException();
    }

    public void OnNothingSelectNotify()
    {
        _gridLine.HideLine();

        if (_tempPath != null)
        {
            _tempPath.Clear();
        }
    }
}

