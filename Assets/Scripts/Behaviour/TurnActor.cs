using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class TurnActor : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 10)] int _maxTurnPoints = 2;

    //Used to indicate if actor should be called for Steps
    public bool isDead { get; private set; }

    public Target target { get; private set;}

    public Team team { get; private set; }
    
    public int maxTurnPoints
    {
        get
        {
            return _maxTurnPoints;
        }
    }

    public int currentTurnPoints { get; private set; }

    Action _startTurnCallback;
    Action _endTurnCallback;

    private void Awake()
    {
        target = GetComponent<Target>();

        currentTurnPoints = maxTurnPoints;
    }

    public void SetTeam(Team team)
    {
        this.team = team;
    }

    public void StartTurn()
    {
        currentTurnPoints = maxTurnPoints;

        if (_startTurnCallback != null)
        {
            _startTurnCallback.Invoke();
        }
    }

    public void EndTurn()
    {
        if (_endTurnCallback != null)
        {
            _endTurnCallback.Invoke();
        }

    }

    public void StartStep(int cost)
    {
        currentTurnPoints -= cost;

        if (currentTurnPoints < 0)
        {
            currentTurnPoints = 0;
        }

        //        Debug.Log(name + " starting step. Remaining turn points: " + currentTurnPoints);
        team.ActorStartedStep(this);

    }
    public void EndStep()
    {
        if (currentTurnPoints <= 0)
        {
            team.ActorFinishedTurn(this);
        }
        else
        {
            team.ActorFinishedStep(this);
        }


    }

    public void AddStartTurnListener(Action callback)
    {
        _startTurnCallback += callback;
    }

    public void AddEndTurnListener(Action callback)
    {
        _endTurnCallback += callback;
    }
}
