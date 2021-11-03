using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct Score
{
    public readonly float value;
    public readonly float maxValue;

    public Score(float value, float maxValue)
    {
        this.value = value;
        this.maxValue = maxValue;
    }
}
