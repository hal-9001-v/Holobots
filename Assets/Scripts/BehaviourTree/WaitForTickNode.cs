using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaitForTickNode : BehaviourNode
{

    public WaitForTickNode() : base(null, NodeType.WaitForTick)
    {

    }

    public WaitForTickNode(BehaviourNode parent) : base(parent, null, NodeType.WaitForTick)
    {

    }

    public WaitForTickNode(BehaviourNode parent, BehaviourNode child) : base(parent, null, NodeType.WaitForTick)
    {
        children.Add(child);
    }
}
