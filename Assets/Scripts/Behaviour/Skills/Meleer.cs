using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Meleer : MonoBehaviour
{
    Ground _ground;

    private void Awake()
    {
        _ground = FindObjectOfType<Ground>();
    }





}