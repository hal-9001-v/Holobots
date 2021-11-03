using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface ISelectorObserver
{
    /// <summary>
    /// When this unit is selected by controlling player, execute every time right click is pressed over a selectable object
    /// </summary>
    /// <param name="selectable"></param>
    public void OnRightClickNotify(Selectable selectable);
    
    /// <summary>
    /// When this unit is selected by controlling player, execute every time Left click is pressed over a selectable object
    /// </summary>
    /// <param name="selectable"></param>
    public void OnLeftClickNotify(Selectable selectable);
    
    /// <summary>
    /// When this unit is selected by controlling player, execute every time mouse passes over a selectable object
    /// </summary>
    /// <param name="selectable"></param>
    public void OnSelectNotify(Selectable selectable);
    
    /// <summary>
    ///Add OnRightClickNotify, OnLeftClickNotify... to subject object(Probably GameDirector)
    /// </summary>
    /// <param name="selectable"></param>
    public void SetNotifications();
}
