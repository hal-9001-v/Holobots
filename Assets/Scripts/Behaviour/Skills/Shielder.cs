using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Shielder : MonoBehaviour
{
    [Header("Referenes")]
    [SerializeField] Shield[] _protectingShields;
    [SerializeField] Shield _planningShield;


    [Header("Settings")]
    [SerializeField] [Range(1, 10)] int _range = 2;
    [SerializeField] [Range(1, 10)] int _shieldCost = 1;

    public int maxShieldRange
    {
        get
        {
            return _range;
        }
    }

    Target _target;
    TurnActor _actor;

    ChildGiver _childGiver;
    Ground _ground;
    GroundTile _currentTile;

    List<Shield> _undeployedShields;

    public List<GroundTile> avaliableTiles;

    private void Awake()
    {
        _target = GetComponent<Target>();
        _actor = GetComponent<TurnActor>();

        _ground = FindObjectOfType<Ground>();
        avaliableTiles = new List<GroundTile>();

        _undeployedShields = new List<Shield>();
        _childGiver = new ChildGiver(gameObject);

        foreach (var shield in _protectingShields)
        {
            _undeployedShields.Add(shield);
            _childGiver.AddChildToContainer(shield.gameObject);
        }

        _childGiver.AddChildToContainer(_planningShield.gameObject);

        _target.dieAction += _childGiver.GiveChildrenBack;

        _actor.AddStartTurnListener(ResetUndeployedShields);
    }

    private void Start()
    {
        CalculateAvaliableTiles();
    }

    public void CalculateAvaliableTiles()
    {
        if (_currentTile != _target.currentGroundTile || _currentTile == null)
        {
            _currentTile = _target.currentGroundTile;

            avaliableTiles = _ground.GetTilesInRange(_currentTile, _range);
        }
    }

    public void SetProtectingShield(GroundTile tile)
    {
        if (_undeployedShields.Count != 0)
        {
            if (SetShield(tile, _undeployedShields[0]))
            {
                _undeployedShields.RemoveAt(0);

                _actor.StartStep(_shieldCost);
                _actor.EndStep();
            }
        }
    }

    public void SetPlanningShield(GroundTile tile)
    {
        SetShield(tile, _planningShield);

        tile.UnsetShield(_planningShield);


    }

    bool SetShield(GroundTile tile, Shield shield)
    {
        CalculateAvaliableTiles();

        if (!avaliableTiles.Contains(tile)) return false;

        shield.SetTile(tile);

        return true;
    }

    void ResetUndeployedShields()
    {
        _undeployedShields.Clear();

        foreach (var shield in _protectingShields)
        {
            shield.TurnOff();

            _undeployedShields.Add(shield);
        }
    }

    public void HidePlanningShield()
    {
        _planningShield.TurnOff();
    }

    public void ShowPlanningShield()
    {
        _planningShield.TurnOn();
    }

}

class ShielderExecuter
{

}