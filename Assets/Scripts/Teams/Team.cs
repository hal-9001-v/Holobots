using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;



//NOTE: Consider overriding this methods and calling base.OriginalMethod + anything else in such method to extend it.
[Serializable]
public abstract class Team
{
    public TeamTag teamTag { get; private set; }

    public List<TeamTag> enemyTags { get; private set; }

    public List<TurnActor> actors;

    protected List<TurnActor> _actorsInTurn;

    protected GameDirector _gameDirector;

    protected CameraMovement _cameraMovement;
    protected SelectionArrow _selectionArrow;
    protected UIInfoManager _UIManager;

    public abstract void UpdateTeam();

    public Team(TeamTag tag, List<TeamTag> enemyTags)
    {
        this.teamTag = tag;
        this.enemyTags = enemyTags;

        actors = new List<TurnActor>();
        _actorsInTurn = new List<TurnActor>();

        _gameDirector = GameObject.FindObjectOfType<GameDirector>();

        _cameraMovement = GameObject.FindObjectOfType<CameraMovement>();
        _selectionArrow = GameObject.FindObjectOfType<SelectionArrow>();
        _UIManager = GameObject.FindObjectOfType<UIInfoManager>();

        SetActorsOfTeam();
    }

    /// <summary>
    /// Add to actors list every alive unit with this team's tag
    /// </summary>
    public virtual void SetActorsOfTeam()
    {
        actors.Clear();

        foreach (var actor in GetActorsWithTeamTag(teamTag))
        {
            actors.Add(actor);
            actor.SetTeam(this);
        }
    }

    /// <summary>
    /// UpdateTeam() and call StartTurn on every unit belonging to this team. Besides, update _actorsInTurn with all units
    /// </summary>
    public virtual bool StartTurn()
    {
        if (IsTeamAlive())
        {
            foreach (var actor in actors)
            {
                _actorsInTurn.Add(actor);

                actor.StartTurn();
            }

            return true;
        }
        else
        {
            return false;
        }

    }

    public abstract bool IsTeamAlive();

    /// <summary>
    /// Clear _actorsInTurn and EndTurn() for every unit. Besides, call GameDirector.TeamEndedTurn();
    /// </summary>
    public virtual void EndTurn()
    {
        _actorsInTurn.Clear();

        foreach (var actor in actors)
        {
            actor.EndTurn();
        }

        _gameDirector.TeamEndedTurn(this);
    }

    /// <summary>
    /// This should be called for actors on this team with no more action points.
    /// </summary>
    /// <param name="actor"></param>
    public virtual void ActorFinishedTurn(TurnActor actor)
    {
        if (_actorsInTurn.Contains(actor))
        {
            _actorsInTurn.Remove(actor);

            if (_actorsInTurn.Count == 0)
            {
                EndTurn();
            }
        }
    }

    protected abstract void ExecuteNextStep();

    public abstract void ActorFinishedStep(TurnActor actor);

    public abstract void ActorStartedStep(TurnActor actor);

    protected void SetTargetOfCamera(Target target, bool fixCamera)
    {
        _UIManager.SetTargetUnit(target);
        _selectionArrow.SetPosition(target.gameObject);
        _cameraMovement.LookAt(target.transform.position);

        if (fixCamera)
        {
            _cameraMovement.FixLookAt(target.transform);
        }
        else
        {
            _cameraMovement.FreeCamera();
        }

    }

    public static List<TurnActor> GetActorsWithTeamTag(TeamTag tag)
    {
        var allActors = GameObject.FindObjectsOfType<TurnActor>();
        List<TurnActor> actorList = new List<TurnActor>();

        foreach (var actor in allActors)
        {
            if (actor.target.teamTag == tag)
            {
                actorList.Add(actor);
            }
        }

        return actorList;
    }

    public virtual List<Target> GetTargetsOfTeam()
    {
        List<Target> targets = new List<Target>();

        foreach (var actor in actors)
        {
            targets.Add(actor.target);
        }

        return targets;
    }
}
