using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Inherits from Team. Take a look at Team.cs for all virtual methods.
/// </summary>
public class PlayerTeam : Team
{
    InputMapContainer _inputContainer;

    CameraMovement _cameraMovement;

    SkillSelector _skillSelector;

    int _unitIndex;
    public PlayerTeam() : base(TeamTag.Player)
    {
        _inputContainer = GameObject.FindObjectOfType<InputMapContainer>();
        _cameraMovement = GameObject.FindObjectOfType<CameraMovement>();

        _skillSelector = GameObject.FindObjectOfType<SkillSelector>();
        _gameDirector = GameObject.FindObjectOfType<GameDirector>();


        _inputContainer.inputMap.Game.NextUnit.performed += ctx =>
        {
            SelectNextUnit();
        };

        _inputContainer.inputMap.Game.EndTurn.performed += ctx =>
        {
            EndTurn();
        };
    }

    public override void StartTurn()
    {
        base.StartTurn();

        SelectUnit(0);
    }

    public override void EndTurn()
    {
        base.EndTurn();

        _skillSelector.Hide();
    }

    public override void ActorFinishedTurn(TurnActor actor)
    {
        base.ActorFinishedTurn(actor);

        SelectUnit(0);
    }

    // Start is called before the first frame update

    void SelectNextUnit()
    {
        SelectUnit(_unitIndex + 1);
    }

    void SelectUnit(int index)
    {
        if (_actorsInTurn.Count > 0)
        {
            if (index >= _actorsInTurn.Count)
            {
                index = 0;
            }
            else if (_unitIndex < 0)
            {
                index = _actorsInTurn.Count - 1;
            }

            _unitIndex = index;
            _skillSelector.SetSelectedUnit(_actorsInTurn[_unitIndex]);
            _cameraMovement.LookAt(_actorsInTurn[_unitIndex].transform.position);
        }
    }

    public override void ActorFinishedStep(TurnActor actor)
    {
        SelectUnit(0);
    }

    public override void ActorStartedStep(TurnActor actor)
    {
        _skillSelector.Hide();
        
    }
}