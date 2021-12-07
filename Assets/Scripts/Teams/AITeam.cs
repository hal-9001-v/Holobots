using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AITeam : Team
{
    List<Bot> _bots;
    List<Bot> _botsInTurn;

    private CameraMovement _cameraFollower;
    private Transform _cameraTarget;
    private UIInfoManager _uiInfo;
    public AITeam(Transform target) : base(TeamTag.AI)
    {
        _bots = new List<Bot>();
        _botsInTurn = new List<Bot>();
        _cameraTarget = target;
        _uiInfo = GameObject.FindObjectOfType<UIInfoManager>();
        _cameraFollower = GameObject.FindObjectOfType<CameraMovement>();
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
        if (_botsInTurn.Count != 0)
        {
            _uiInfo.currentUnitTarget = (_botsInTurn[0].target);
            _cameraFollower.LookAt(_botsInTurn[0].transform.position);
            _cameraFollower.FixLookAt(_botsInTurn[0].transform);

            _botsInTurn[0].ExecuteStep();
        }
    }



    void BotEndedStep(TurnActor actor)
    {
        ExecuteBotStep();
    }

    public override void UpdateTeam()
    {
        _bots.Clear();

        foreach (var actorBot in GameObject.FindObjectsOfType<Bot>())
        {
            if (actorBot.actor.teamTag == tag)
            {
                _bots.Add(actorBot);
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
