using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameDirector : MonoBehaviour
{
    int _steppingActorCounter;

    TurnActor[] _actors;

    PlayerSelector _playerSelector;

    public bool allActorsEnded
    {
        get
        {
            foreach (var actor in _actors)
            {
                if (!actor.isTurnEnded)
                    return false;
            }

            return true;
        }
    }

    enum GameStates
    {
        Decide,
        Step,
        EndOfStep
    }

    GameStates _currentState;

    private void Awake()
    {
        _actors = FindObjectsOfType<TurnActor>();
        _playerSelector = FindObjectOfType<PlayerSelector>();

    }

    private void Start()
    {
        ChangeState(GameStates.Decide);
    }

    void StepActors()
    {
        _steppingActorCounter = 0;

        for (int i = 0; i < _actors.Length; i++)
        {
            if (!_actors[i].isTurnEnded)
            {
                _steppingActorCounter++;
                _actors[i].StartStep();
            }
        }

        if (_steppingActorCounter == 0)
        {
            ChangeState(GameStates.Decide);
        }

    }

    void ChangeState(GameStates nextState)
    {
        _currentState = nextState;

        switch (nextState)
        {
            case GameStates.Decide:
                PrepareAI();
                _playerSelector.EnableControl();
                break;

            case GameStates.Step:

                _playerSelector.DisableControl();

                StepActors();
                break;

            case GameStates.EndOfStep:

                if (allActorsEnded)
                {
                    ChangeState(GameStates.Decide);
                }
                else
                {
                    ChangeState(GameStates.Step);
                }

                return;

            default:
                break;
        }

    }

    void PrepareAI()
    {
        foreach (var unit in FindObjectsOfType<Bot>())
        {
            if (!unit.isDead)
            {
                unit.PrepareSteps();
            }
        }
    }

    public void ExecuteSteps()
    {
        if (_currentState == GameStates.Decide)
        {
            ChangeState(GameStates.Step);
        }

    }

    public void ActorEndedStep()
    {
        _steppingActorCounter--;

        if (_steppingActorCounter <= 0)
        {
            _steppingActorCounter = 0;

            ChangeState(GameStates.EndOfStep);
        }


    }

}
