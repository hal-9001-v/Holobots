using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MobTeam : Team
{
    List<Bot> _bots;
    List<Bot> _botsInTurn;

    public MobTeam() : base(TeamTag.Mob)
    {
        _bots = new List<Bot>();
        _botsInTurn = new List<Bot>();

        UpdateTeam();
        _gameDirector = GameObject.FindObjectOfType<GameDirector>();
    }

    public override bool StartTurn()
    {
        UpdateTeam();

        _botsInTurn.Clear();

        foreach (var bot in _bots)
        {
            _botsInTurn.Add(bot);

            bot.actor.SetTeam(this);

            bot.actor.StartTurn();
        }

        if (_botsInTurn.Count != 0)
        {
            ExecuteBotStep();
            return true;
        }
        else
        {
            EndTurn();
            return false;
        }
    }

    void ExecuteBotStep()
    {
        _botsInTurn[0].ExecuteStep();
    }

    void BotEndedStep(TurnActor actor)
    {
        ExecuteBotStep();
    }

    public override void UpdateTeam()
    {
        _bots.Clear();

        var bots = GameObject.FindObjectsOfType<Bot>();

        if (bots != null && bots.Length > 0)
        {
            foreach (var actorBot in bots)
            {
                if (actorBot.actor.teamTag == tag)
                {
                    _bots.Add(actorBot);
                }
            }
        }
    }

    public override void ActorFinishedTurn(TurnActor actor)
    {
        var bot = actor.GetComponent<Bot>();

        if (bot)
        {
            if (_botsInTurn.Contains(bot))
            {
                _botsInTurn.Remove(bot);

                if (_botsInTurn.Count == 0)
                {
                    EndTurn();
                }
                else
                {
                    ExecuteBotStep();
                }
            }
        }


    }

    public override void ActorFinishedStep(TurnActor actor)
    {
        ExecuteBotStep();
    }

    public override void ActorStartedStep(TurnActor actor)
    {
    }
}
