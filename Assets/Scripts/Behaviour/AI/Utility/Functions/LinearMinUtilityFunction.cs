using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LinearMinUtilityFunction : UtilityFunction
{
    float min;

    public LinearMinUtilityFunction(float min)
    {
        this.min = min;
    }

    public override float GetValue(Score score)
    {
        if (score.value > score.maxValue)
        {
            return min;
        }

        var value = (1 - score.value / score.maxValue) + min;

        if (value >= 1)
        {
            return 1;
        }

        return value;
    }
}
