using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AITeam : Team
{
    List<Bot> _bots;
    List<Bot> _botsInTurn;

    private Transform _cameraTarget;
    private UIInfoManager _uiInfo;
    public AITeam(Transform target, TeamTag tag, List<TeamTag> enemyTags) : base(tag, enemyTags)
    {
        _botsInTurn = new List<Bot>();
        _cameraTarget = target;
        _uiInfo = GameObject.FindObjectOfType<UIInfoManager>();

        _gameDirector = GameObject.FindObjectOfType<GameDirector>();
    }

    public override bool StartTurn()
    {
        _botsInTurn.Clear();

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
            SetTargetOfCamera(_botsInTurn[0].target);
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

                UpdateBots();

                if (_botsInTurn.Count == 0)
                {
                    EndTurn();
                }
                else
                {
                    ExecuteNextStep();
                }
            }
        }
    }

    private void UpdateBots()
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
        ExecuteNextStep();
    }

    public override void ActorStartedStep(TurnActor actor)
    {
    }
}
