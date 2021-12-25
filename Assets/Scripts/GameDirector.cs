using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
public class GameDirector : MonoBehaviour
{
    [Header("References")]
    [SerializeField] Transform cameraTarget;
    [SerializeField] TextMeshProUGUI winningtext;

    [SerializeField] TaggedTeam[] _taggedTeams;

    List<Team> _teams;
    BehaviourTree _teamTurnTree;

    UIInfoManager uiInfo;
    public UIInfoManager handUiInfo;
    public UIInfoManager deskUiInfo;
    DeathMenuManager _deathMenuManager;

    int _currentTeam = -1;

    enum GameStates
    {
        Intro,
        StartTurn,
        EndTurn,
        EndGame
    }

    private void Awake()
    {
        Time.timeScale = 0.75f;
        _deathMenuManager = FindObjectOfType<DeathMenuManager>();

        if(SystemInfo.deviceType == DeviceType.Handheld) uiInfo = handUiInfo;
        else uiInfo = deskUiInfo;
        
        CreateTeams();
    }

    private void Start()
    {

        if (_teams.Count != 0)
        {
            ChangeState(GameStates.Intro);
        }
        else
        {
            Debug.LogWarning("No teams in Scene!");
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

                StartTeamTurn();

                break;

            case GameStates.EndTurn:

                ChangeState(GameStates.StartTurn);

                break;

            case GameStates.EndGame:
                winningtext.text = "End Game, winner: " + _teams[0].teamTag;
                _deathMenuManager.DisplayEndgameScreen(_teams[0].teamTag);

                return;

            default:
                break;
        }

    }

    void CreateTeams()
    {
        //Add low priority teams first
        _teams = new List<Team>();

        foreach (var taggedTeam in _taggedTeams)
        {
            switch (taggedTeam.teamTag)
            {
                case TeamTag.Player1:
                    _teams.Add(new PlayerTeam(cameraTarget, TeamTag.Player1, taggedTeam.enemyTeamTag, uiInfo));
                    break;
                case TeamTag.Player2:
                    _teams.Add(new PlayerTeam(cameraTarget, TeamTag.Player2, taggedTeam.enemyTeamTag, uiInfo));
                    break;
                case TeamTag.AI:
                    _teams.Add(new AITeam(cameraTarget, TeamTag.AI, taggedTeam.enemyTeamTag, uiInfo));
                    break;
                case TeamTag.AI2:
                    _teams.Add(new AITeam(cameraTarget, TeamTag.AI2, taggedTeam.enemyTeamTag,uiInfo));
                    break;
                case TeamTag.Mob:
                    _teams.Add(new AITeam(cameraTarget, TeamTag.Mob, taggedTeam.enemyTeamTag,uiInfo));
                    break;
                case TeamTag.None:
                    break;
                default:
                    throw new Exception("That team is not handled!");
            }
        }
    }

    void StartTeamTurn()
    {
        _currentTeam++;

        if (_currentTeam >= _teams.Count)
        {
            _currentTeam = 0;
        }

        if (_teams.Count == 1)
        {
            ChangeState(GameStates.EndGame);
        }

        if (_teams[_currentTeam].StartTurn())
        {
            Debug.Log("Start Turn of " + _teams[_currentTeam].teamTag);
        }
        else
        {
            _teams.RemoveAt(_currentTeam);

            StartTeamTurn();

        }
    }

    public bool UpdateTeams()
    {
        for (int i = 0; i < _teams.Count; i++)
        {
            _teams[i].UpdateTeam();

            if (!_teams[i].IsTeamAlive())
            {
                _teams.RemoveAt(i);
            }
        }

        if (_teams.Count > 1)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    public List<Target> GetTargetsOfTeam(TeamTag teamTag)
    {
        foreach (var team in _teams)
        {
            if (team.teamTag == teamTag)
            {
                return team.GetTargetsOfTeam();
            }
        }

        return new List<Target>();
    }

    public List<Target> GetTargetsOfTeams(List<TeamTag> teamTags)
    {
        List<Target> targets = new List<Target>();

        foreach (var teamTag in teamTags)
        {
            foreach (var target in GetTargetsOfTeam(teamTag))
            {
                targets.Add(target);
            }
        }

        return targets;
    }

    public List<Target> GetTargetsOfTeamWithTag(TeamTag teamTag, TargetType targetType)
    {
        List<Target> targets = new List<Target>();

        foreach (var target in GetTargetsOfTeam(teamTag))
        {
            if (target.targetType == targetType)
            {
                targets.Add(target);
            }
        }

        return targets;
    }

    public List<Target> GetTargetsOfTeamWithTag(List<TeamTag> teamTags, TargetType targetType)
    {
        List<Target> targets = new List<Target>();

        foreach (var target in GetTargetsOfTeams(teamTags))
        {
            if (target.targetType == targetType)
            {
                targets.Add(target);
            }
        }

        return targets;
    }

    public void TeamEndedTurn(Team team)
    {
        if (team == _teams[_currentTeam])
        {
            StartCoroutine(EndTurnCountdown());
        }
    }

    IEnumerator EndTurnCountdown()
    {
        yield return new WaitForSeconds(0.5f);
        ChangeState(GameStates.EndTurn);

    }

    [ContextMenu("Tick")]
    void TickTree()
    {
        _teamTurnTree.Tick();
    }

    [Serializable]
    class TaggedTeam
    {
        public TeamTag teamTag;
        public List<TeamTag> enemyTeamTag;

        public Team team { get; private set; }

        public void SetTeam(Team team)
        {
            this.team = team;
        }
    }
}
