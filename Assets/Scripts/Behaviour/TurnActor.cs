using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class TurnActor : MonoBehaviour
{
    //Used to indicate if actor should be called for Steps
    public bool isDead { get; private set; }

    public bool isTurnEnded
    {
        get
        {
            return _steps.Count == 0;
        }
    }

    Queue<TurnStep> _steps;

    Target _target;

    GameDirector _gameDirector;

    private void Awake()
    {
        _steps = new Queue<TurnStep>();

        _target = GetComponent<Target>();
        _gameDirector = FindObjectOfType<GameDirector>();
    }

    private void Start()
    {
        _target.dieAction += Die;
    }

    void Die()
    {
        isDead = true;

        _steps.Clear();
    }

    public void ResetSteps()
    {
        _steps.Clear();
    }

    public void StartStep()
    {
        if (_steps.Count != 0)
        {
            var turnStep = _steps.Dequeue();

            turnStep.Execute();
        }
    }

    public void EndStep()
    {
        _gameDirector.ActorEndedStep();
    }

    public void AddSteps(TurnStep[] steps)
    {
        foreach (var step in steps)
        {
            _steps.Enqueue(step);
        }
    }

    public void AddStep(TurnStep step)
    {
        _steps.Enqueue(step);
    }

}
