using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Meleer : MonoBehaviour
{
    [Header("References")]
    [SerializeField] MeleeHit _hit;
    [SerializeField] MeleeHit _planningHit;

    Ground _ground;

    private void Awake()
    {
        _ground = FindObjectOfType<Ground>();
    }

    public void SetHit(GroundTile tile)
    {
        _hit.SetTile(tile);
    }

    public void SetPlanningHit(GroundTile tile)
    {
        _planningHit.SetTile(tile);
    }

    public void Hide()
    {
        _hit.Hide();
        _planningHit.Hide();
    }



}