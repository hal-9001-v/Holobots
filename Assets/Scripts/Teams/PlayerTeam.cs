using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Inherits from Team. Take a look at Team.cs for all virtual methods.
/// </summary>
public class PlayerTeam : Team
{
    GameInput inputContainer;

    SkillSelector _skillSelector;

    int _unitIndex;

    bool _turnIsActive;

    public PlayerTeam(Transform target, TeamTag teamTag, List<TeamTag> enemyTags, UIInfoManager deviceUiInfo) : base(teamTag, enemyTags, deviceUiInfo)
    {
        inputContainer = new GameInput();

        _skillSelector = GameObject.FindObjectOfType<SkillSelector>();
        _gameDirector = GameObject.FindObjectOfType<GameDirector>();

        inputContainer.Game.NextUnit.Enable();
        inputContainer.Game.EndTurn.Enable();
        inputContainer.Game.SelectAbility1.Enable();
        inputContainer.Game.SelectAbility2.Enable();
        inputContainer.Game.SelectAbility3.Enable();
        inputContainer.Game.SelectAbility4.Enable();

        inputContainer.Game.NextUnit.performed += ctx =>
        {
            if (_turnIsActive)
            {
                SelectNextUnit();
            }
        };

        inputContainer.Game.EndTurn.performed += ctx =>
        {
            if (_turnIsActive)
            {
                if (_gameDirector)
                {
                    EndTurn();
                }
            }
        };

        inputContainer.Game.SelectAbility1.performed += ctx =>
        {
            if (_turnIsActive)
            {
                _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[0]);
            }

        };
        inputContainer.Game.SelectAbility2.performed += ctx =>
        {
            if (_turnIsActive)
            {
                _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[1]);
            }

        }; inputContainer.Game.SelectAbility3.performed += ctx =>
        {
            if (_turnIsActive)
            {
                _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[2]);
            }

        }; inputContainer.Game.SelectAbility4.performed += ctx =>
        {
            if (_turnIsActive)
            {
                _skillSelector.SetSelectedSkill(_skillSelector.skillHolders[3]);
            }
        };
    }

    public override bool StartTurn()
    {
        _turnIsActive = true;
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
        _turnIsActive = false;

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
