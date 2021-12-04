using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IPlayerUnitBehaviour
{
    /// <summary>
    /// Start Control over this unit
    /// </summary>
    public void StartControlling();

    /// <summary>
    ///Stop Control over this unit
    /// </summary>
    public void StopControlling();

}
