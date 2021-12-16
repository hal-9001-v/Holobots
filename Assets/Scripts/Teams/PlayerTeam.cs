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

    SkillSelector _skillSelector;

    int _unitIndex;
    public PlayerTeam(Transform target, List<TeamTag> enemyTags) : base(TeamTag.Player, enemyTags)
    {
        _inputContainer = GameObject.FindObjectOfType<InputMapContainer>();

        _skillSelector = GameObject.FindObjectOfType<SkillSelector>();
        _gameDirector = GameObject.FindObjectOfType<GameDirector>();

        _inputContainer.inputMap.Game.NextUnit.Enable();
        _inputContainer.inputMap.Game.EndTurn.Enable();
        _inputContainer.inputMap.Game.SelectAbility1.Enable();
        _inputContainer.inputMap.Game.SelectAbility2.Enable();
        _inputContainer.inputMap.Game.SelectAbility3.Enable();
        _inputContainer.inputMap.Game.SelectAbility4.Enable();

        _inputContainer.inputMap.Game.NextUnit.performed += ctx =>
        {
            SelectNextUnit();
        };

        _inputContainer.inputMap.Game.EndTurn.performed += ctx =>
        {
            EndTurn();
        };
        _inputContainer.inputMap.Game.SelectAbility1.performed += ctx =>
        {

            _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[0]);

        };
        _inputContainer.inputMap.Game.SelectAbility2.performed += ctx =>
        {

            _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[1]);

        }; _inputContainer.inputMap.Game.SelectAbility3.performed += ctx =>
        {

            _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[2]);

        }; _inputContainer.inputMap.Game.SelectAbility4.performed += ctx =>
        {

            _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[3]);

        };
    }

    public override bool StartTurn()
    {
        _gameDirector.UpdateTeams();

        if (base.StartTurn())
        {
            SelectUnit(0);

            return true;
        }

        return false;
    }

    public override void EndTurn()
    {
        base.EndTurn();
        _skillSelector.Hide();
    }

    public override void UpdateTeam()
    {
        for (int i = 0; i < actors.Count; i++)
        {
            if (actors[i].target.isAlive == false)
            {
                if (_actorsInTurn.Contains(actors[i]))
                {
                    _actorsInTurn.Remove(actors[i]);
                }

                actors.RemoveAt(i);

            }
        }
    }

    public override void ActorFinishedTurn(TurnActor actor)
    {
        if (_actorsInTurn.Contains(actor))
        {
            _actorsInTurn.Remove(actor);

            _gameDirector.UpdateTeams();

            if (_actorsInTurn.Count == 0)
            {
                EndTurn();
            }
            else
            {
                SelectUnit(0);

                SetTargetOfCamera(_actorsInTurn[0].target, false);
            }
        }

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

            SetTargetOfCamera(_actorsInTurn[_unitIndex].target, false);
        }
    }

    public override void ActorFinishedStep(TurnActor actor)
    {
        _gameDirector.UpdateTeams();

        SelectUnit(_unitIndex);
    }

    public override void ActorStartedStep(TurnActor actor)
    {
        GameObject.FindObjectOfType<SelectionArrow>().SetPosition(_actorsInTurn[_unitIndex].gameObject);

        _cameraMovement.FixLookAtC(_actorsInTurn[_unitIndex].transform);
        _skillSelector.Hide();

    }

    protected override void ExecuteNextStep()
    {
        throw new NotImplementedException();
    }
}
