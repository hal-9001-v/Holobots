using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Shielder : MonoBehaviour
{
    [Header("Referenes")]
    [SerializeField] Shield _protectingShield;
    [SerializeField] Shield _planningShield;

    [Header("Settings")]
    [SerializeField] [Range(1, 10)] int _range = 2;
    Target _target;

    Ground _ground;
    GroundTile _currentTile;

    public List<GroundTile> avaliableTiles;

    bool _isFacingX;

    private void Awake()
    {
        _target = GetComponent<Target>();

        _ground = FindObjectOfType<Ground>();
        avaliableTiles = new List<GroundTile>();

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
        SetShield(tile, _protectingShield);
    }

    public void SetPlanningShield(GroundTile tile)
    {
        SetShield(tile, _planningShield);
    }

    void SetShield(GroundTile tile, Shield shield)
    {
        CalculateAvaliableTiles();

        if (!avaliableTiles.Contains(tile)) return;

        shield.SetTile(tile);
    }

    public void RotateShield()
    {
        if (_isFacingX)
        {

        }
        //It is facing Z
        else
        {

        }

        _isFacingX = !_isFacingX;
    }

    public void HideShields()
    {
        _protectingShield.TurnOff();
        _planningShield.TurnOff();
    }

    public void ShowShields()
    {
        _protectingShield.TurnOn();
        _planningShield.TurnOn();
    }

}
