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

    private Transform _cameraTarget;
    private UIInfoManager _uiInfo;
     
    int _unitIndex;
    public PlayerTeam(Transform target) : base(TeamTag.Player)
    {
        _inputContainer = GameObject.FindObjectOfType<InputMapContainer>();
        _cameraMovement = GameObject.FindObjectOfType<CameraMovement>();
        _uiInfo = GameObject.FindObjectOfType<UIInfoManager>();
        _cameraTarget = target;
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
        _inputContainer.inputMap.Game.SelectAbility1.performed += ctx => {

            _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[0]);

        };
         _inputContainer.inputMap.Game.SelectAbility2.performed += ctx => {

            _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[1]);

        }; _inputContainer.inputMap.Game.SelectAbility3.performed += ctx => {

            _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[2]);

        }; _inputContainer.inputMap.Game.SelectAbility4.performed += ctx => {

            _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[3]);

        };
    }

    public override bool StartTurn()
    {
        _cameraMovement.FixLookAt(_cameraTarget);
        base.StartTurn();
        SelectUnit(0);

        return true;
    }

    public override void EndTurn()
    {
        base.EndTurn();
        _skillSelector.Hide();
    }

    public override void ActorFinishedTurn(TurnActor actor)
    {
        _cameraMovement.FixLookAt(_cameraTarget);
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
            _uiInfo.currentUnitTarget = _actorsInTurn[_unitIndex].GetTargetType();
        }
    }

    public override void ActorFinishedStep(TurnActor actor)
    {
        _cameraMovement.FixLookAt(_cameraTarget);
        SelectUnit(0);
    

    }

    public override void ActorStartedStep(TurnActor actor)
    {
        _cameraMovement.FixLookAt(_actorsInTurn[_unitIndex].transform);
        _skillSelector.Hide();

    }
}
