using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameDirector : MonoBehaviour
{
    List<Team> _teams;

    BehaviourTree _teamTurnTree;

    Team _teamInTurn;
    [SerializeField] Transform cameraTarget;
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

        FullSequenceNode rootNode = new FullSequenceNode();
        rootNode.name = "Root";
        _teamTurnTree.root = rootNode;


        foreach (var team in _teams)
        {
            SequenceNode sequenceNode = new SequenceNode(rootNode);
            sequenceNode.name = "Turn of: " + team.teamTag.ToString();

            LeafNode startTurnNode = new LeafNode(sequenceNode, () =>
            {
                StartTeamTurn(team);
                return true;
            });
            startTurnNode.name = "Start turn of";

            WaitForTickNode waitforTickNode = new WaitForTickNode(sequenceNode);
            waitforTickNode.name = "Wait of " + team.teamTag.ToString();

            LeafNode endTurnNode = new LeafNode(waitforTickNode, () =>
            {
//                Debug.Log("End turn of " + team.teamTag.ToString());
                TickTree();
                return true;
            });
            endTurnNode.name = "End of " + team.teamTag.ToString();
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

        _teams.Add(new MobTeam(cameraTarget));
        _teams.Add(new AITeam(cameraTarget, TeamTag.AI));
        _teams.Add(new AITeam(cameraTarget, TeamTag.AI2));
        _teams.Add(new PlayerTeam(cameraTarget));

        foreach (var team in _teams)
        {
            team.UpdateTeam();
        }
    }

    void StartTeamTurn(Team team)
    {
        _teamInTurn = team;
        team.StartTurn();

//        Debug.Log("Start Turn of " + team.teamTag);
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
