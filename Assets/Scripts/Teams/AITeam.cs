using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AITeam : Team
{
    List<Bot> _bots;
    List<Bot> _botsInTurn;

    private CameraMovement _cameraFollower;
    private Transform _cameraTarget;
    public AITeam(Transform target) : base(TeamTag.AI)
    {
        _bots = new List<Bot>();
        _botsInTurn = new List<Bot>();
        _cameraTarget = target;
        _cameraFollower = GameObject.FindObjectOfType<CameraMovement>();
        UpdateTeam();
        _gameDirector = GameObject.FindObjectOfType<GameDirector>();
    }

    public override void StartTurn()
    {
        UpdateTeam();

        _botsInTurn.Clear();

        foreach (var bot in _bots)
        {
            _botsInTurn.Add(bot);

            bot.actor.SetTeam(this);
        }

        ExecuteBotStep();
    }

    void ExecuteBotStep()
    {
        _botsInTurn[0].ExecuteStep();
        _cameraFollower.LookAt(_botsInTurn[0].transform.position);
        _cameraFollower.FixLookAt(_botsInTurn[0].transform);
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
