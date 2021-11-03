using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThresholdUtilityFunction : UtilityFunction
{
    float _threshold;
    public ThresholdUtilityFunction(float threshold)
    {
        _threshold = threshold;
    }

    public override float GetValue(Score score)
    {
        if (score.value >= _threshold)
        {
            return 1;
        }

        return 0;
    }
}
