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

    /// <summary>
    /// Erase all step calculation on this unit
    /// </summary>
    public void ResetSteps();

    /// <summary>
    ///Add desired steps to TurnActor
    /// </summary>
    /// <param name="steps"></param>
    public void AddSteps(TurnStep[] steps);

    /// <summary>
    ///Add desired step to TurnActor
    /// </summary>
    /// <param name="steps"></param>
    public void AddStep(TurnStep step);

}
