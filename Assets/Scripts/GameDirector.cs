using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameDirector : MonoBehaviour
{
    List<Team> _teams;

    BehaviourTree _teamTurnTree;

    Team _teamInTurn;

    enum GameStates
    {
        Intro,
        StartTurn,
        EndTurn,
        EndGame
    }

    private void Start()
    {
        CreateTeams();

        SetTeamTurnTree();

        ChangeState(GameStates.Intro);
    }

    void SetTeamTurnTree()
    {
        _teamTurnTree = new BehaviourTree();

        SequenceNode rootNode = new SequenceNode(null);
        _teamTurnTree.root = rootNode;

        foreach (var team in _teams)
        {
            SequenceNode startTurnNode = new SequenceNode(rootNode, () =>
            {
                StartTeamTurn(team);
            });

            startTurnNode.name = "Start turn of " + team.tag.ToString();

            WaitForTickNode waitforTickNode = new WaitForTickNode(startTurnNode, null);
            waitforTickNode.name = "Wait of " + team.tag.ToString();

            LeafNode endTurnNode = new LeafNode(waitforTickNode, null);
            endTurnNode.name = "End of " + team.tag.ToString();
        }
    }

    void ChangeState(GameStates nextState)
    {
        switch (nextState)
        {
            case GameStates.Intro:
                ChangeState(GameStates.StartTurn);
                break;

            case GameStates.StartTurn:

                _teamTurnTree.StartTree(() =>
                {
                    ChangeState(GameStates.EndTurn);
                });

                break;

            case GameStates.EndTurn:

                ChangeState(GameStates.StartTurn);

                break;

            case GameStates.EndGame:


                return;

            default:
                break;
        }

    }

    void CreateTeams()
    {
        //Add low priority teams first
        _teams = new List<Team>();

        _teams.Add(new MobTeam());
        _teams.Add(new AITeam());
        _teams.Add(new PlayerTeam());

        foreach (var team in _teams)
        {
            team.UpdateTeam();
        }
    }

    void StartTeamTurn(Team team)
    {
        _teamInTurn = team;
        team.StartTurn();

        Debug.Log("Start Turn of " + team);
    }

    public void TeamEndedTurn(Team team)
    {
        if (team == _teamInTurn)
        {
            _teamTurnTree.Tick();
        }
    }

    [ContextMenu("Tick")]
    void TickTree()
    {
        _teamTurnTree.Tick();
    }
}
