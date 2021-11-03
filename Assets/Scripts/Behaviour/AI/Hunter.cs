using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Mover))]
[RequireComponent(typeof(Shooter))]
public class Hunter : Bot
{
    Mover _mover;
    Shooter _shooter;

    Target _target;
    Target _selectedTarget;

    private void Awake()
    {
        _target = GetComponent<Target>();
        _mover = GetComponent<Mover>();
        _shooter = GetComponent<Shooter>();
    }



    private void Start()
    {
        _target.dieAction += Dead;
    }

    public override void PrepareSteps()
    {
        var targets = FindObjectsOfType<PlayerUnit>();

        _selectedTarget = targets[Random.Range(0, targets.Length)].GetComponent<Target>();

        _mover.ResetSteps();
        _mover.AddPathToSteps(_mover.GetFilteredPath(_target.currentGroundTile, _selectedTarget.currentGroundTile));

        _shooter.ResetSteps();
        _shooter.AddShootStep(_selectedTarget.currentGroundTile);
    }

    void Dead()
    {
        foreach (var renderer in GetComponentsInChildren<Renderer>())
        {
            renderer.enabled = false;
        }

        foreach (var collider in GetComponentsInChildren<Collider>())
        {
            collider.enabled = false;
        }
    }

    public override TurnPreview[] GetPossibleMoves()
    {
        int range = 4;

        var moves = _mover.GetTilesInMaxRange(range);

        TurnPreview[] preview = new TurnPreview[moves.Count];

        for (int i = 0; i < moves.Count; i++)
        {
            preview[i] = new TurnPreview();
            preview[i].position = moves[i];
        }

        return preview;
    }

    public override MinMaxWeights GetMinMaxWeights()
    {
        throw new System.NotImplementedException();
    }
}
