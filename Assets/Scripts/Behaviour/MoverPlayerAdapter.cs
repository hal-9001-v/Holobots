using System.Collections.Generic;
using UnityEngine;
public class MoverPlayerAdapter : Adapter, ISelectorObserver
{
    //Lines and Path Finding
    GridLine _gridLine;

    Mover _mover;
    Target _target;
    TurnActor _turnActor;

    //Sum of _tempPats
    List<GroundTile> _confirmedPath;
    //_confirmedPath's extension
    List<GroundTile> _tempPath;

    public MoverPlayerAdapter(Mover mover, Target target, TurnActor actor)
    {
        _mover = mover;
        _target = target;
        _turnActor = actor;

        _confirmedPath = new List<GroundTile>();
        _tempPath = new List<GroundTile>();

        _gridLine = GameObject.FindObjectOfType<GridLineProvider>().CloneMovementGridLine(mover.name);

        SetNotifications();
    }

    List<GroundTile> JoinPaths(List<GroundTile> a, List<GroundTile> b)
    {
        List<GroundTile> newList = new List<GroundTile>();

        foreach (GroundTile tile in a)
        {
            newList.Add(tile);
        }

        foreach (GroundTile tile in b)
        {
            newList.Add(tile);
        }

        return newList;

    }

    public void OnRightClickNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        //Update Path
        _confirmedPath = JoinPaths(_confirmedPath, _tempPath);

        _mover.AddStepsFromPath(_tempPath);

    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        if (_gridLine)
        {
            var destination = selectable.GetComponent<GroundTile>();

            if (destination)
            {
                _tempPath = _mover.GetFilteredPath(_mover.lastPathTile, destination);

                var totalPath = JoinPaths(_confirmedPath, _tempPath);
                Vector3[] points = new Vector3[totalPath.Count];

                for (int i = 0; i < totalPath.Count; i++)
                {
                    points[i] = totalPath[i].transform.position;
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

    }

    public override void Reset()
    {
        _gridLine.HideLine();

        _confirmedPath.Clear();
        _tempPath.Clear();

        _mover.ResetSteps();
    }

    public override void OnStopControl()
    {
        _tempPath.Clear();

        Vector3[] points = new Vector3[_confirmedPath.Count];

        for (int i = 0; i < _confirmedPath.Count; i++)
        {
            points[i] = _confirmedPath[i].transform.position;
        }

        _gridLine.SetPoints(points);

    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        throw new System.NotImplementedException();
    }

    public override void OnStartControl()
    {
        //Nothing!

    }

}

