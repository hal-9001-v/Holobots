using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Sensor
{
    public UtilityFunction function { get; private set; }

    public Sensor(UtilityFunction function)
    {
        this.function = function;
    }

    protected List<TeamTag> GetTeamTagMask(TeamTag teamTag)
    {
        List<TeamTag> mask = new List<TeamTag>();
        switch (teamTag)
        {
            case TeamTag.Player:
                mask.Add(TeamTag.Player);
                break;
            case TeamTag.AI:
                mask.Add(TeamTag.AI);
                break;
            case TeamTag.AIorPlayer:
                mask.Add(TeamTag.AI);
                mask.Add(TeamTag.Player);
                break;
            case TeamTag.None:
                break;

            default:
                break;
        }

        return mask;
    }

    public abstract float GetScore();


}
