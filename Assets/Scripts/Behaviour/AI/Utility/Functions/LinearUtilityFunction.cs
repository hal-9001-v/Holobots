using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LinearUtilityFunction : UtilityFunction
{
    public override float GetValue(Score score)
    {
        return score.value / score.maxValue;
    }

}
