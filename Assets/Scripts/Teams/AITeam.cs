using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AITeam : Team
{
    List<Bot> _bots;
    List<Bot> _botsInTurn;

    public AITeam(TeamTag tag, List<TeamTag> enemyTags, UIInfoManager deviceUIInforManager) : base(tag, enemyTags, deviceUIInforManager)
    {
        _botsInTurn = new List<Bot>();

        _gameDirector = GameObject.FindObjectOfType<GameDirector>();
    }

    public override bool StartTurn()
    {
        _botsInTurn.Clear();
        _gameDirector.UpdateTeams();

        foreach (var bot in _bots)
        {
            _botsInTurn.Add(bot);

            bot.actor.SetTeam(this);

            bot.actor.StartTurn();
        }


        if (_botsInTurn.Count != 0)
        {
            ExecuteNextStep();

            return true;
        }
        else
        {
            EndTurn();
            return false;
        }
    }

    protected override void ExecuteNextStep()
    {
        if (_botsInTurn.Count != 0)
        {
            SetTargetOfCamera(_botsInTurn[0].target, true);
            _botsInTurn[0].ExecuteStep();
        }
    }


    public override void SetActorsOfTeam()
    {
        _bots = new List<Bot>();

        foreach (var actorBot in GameObject.FindObjectsOfType<Bot>())
        {
            if (actorBot.actor.target.teamTag == teamTag)
            {
                _bots.Add(actorBot);
                actorBot.actor.SetTeam(this);
            }
        }
    }

    public override List<Target> GetTargetsOfTeam()
    {
        List<Target> targets = new List<Target>();

        foreach (var bot in _bots)
        {
            targets.Add(bot.target);
        }

        return targets;
    }

    public override void ActorFinishedTurn(TurnActor actor)
    {
        var bot = actor.GetComponent<Bot>();

        if (bot)
        {
            if (_botsInTurn.Contains(bot))
            {
                _botsInTurn.Remove(bot);

                if (_gameDirector.UpdateTeams())
                {
                    if (_botsInTurn.Count == 0)
                    {
                        EndTurn();
                    }
                    else
                    {
                        ExecuteNextStep();
                    }
                }
                else
                {
                    EndTurn();
                }


            }
        }
    }

    public override void UpdateTeam()
    {
        for (int i = 0; i < _bots.Count; i++)
        {
            if (!_bots[i].target.isAlive)
            {
                if (_botsInTurn.Contains(_bots[i]))
                {
                    _botsInTurn.Remove(_bots[i]);
                }

                _bots.RemoveAt(i);

                i--;
            }
        }
    }

    public override void ActorFinishedStep(TurnActor actor)
    {
        if (_gameDirector.UpdateTeams())
        {
            ExecuteNextStep();
        }
        else
        {
            EndTurn();
        }

    }

    public override void ActorStartedStep(TurnActor actor)
    {
    }

    public override bool IsTeamAlive()
    {
        if (_bots.Count != 0)
        {
            return true;
        }

        return false;

    }
}
