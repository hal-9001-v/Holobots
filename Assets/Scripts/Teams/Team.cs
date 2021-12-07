using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;



//NOTE: Consider overriding this methods and calling base.OriginalMethod + anything else in such method to extend it.
[Serializable]
public abstract class Team
{
    public TeamTag tag;

    public List<TurnActor> actors;

    protected List<TurnActor> _actorsInTurn;

    protected GameDirector _gameDirector;

    public Team(TeamTag tag)
    {
        this.tag = tag;

        actors = new List<TurnActor>();
        _actorsInTurn = new List<TurnActor>();

        _gameDirector = GameObject.FindObjectOfType<GameDirector>();
    }

    /// <summary>
    /// Add to actos list every alive unit with this team's tag
    /// </summary>
    public virtual void UpdateTeam()
    {
        actors.Clear();

        foreach (var actor in GetActorsWithTeamTag(tag))
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
        UpdateTeam();

        if (actors.Count != 0)
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

    public abstract void ActorFinishedStep(TurnActor actor);

    public abstract void ActorStartedStep(TurnActor actor);


    public static List<TurnActor> GetActorsWithTeamTag(TeamTag tag)
    {

        var allActors = GameObject.FindObjectsOfType<TurnActor>();
        List<TurnActor> actorList = new List<TurnActor>();

        foreach (var actor in allActors)
        {
            if (actor.teamTag == tag)
            {
                actorList.Add(actor);
            }
        }

        return actorList;
    }
}
