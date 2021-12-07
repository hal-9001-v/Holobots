using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FullSequenceNode : BehaviourNode
{
    public FullSequenceNode(BehaviourNode parent) : base(parent, null, NodeType.FullSequence)
    {

    }

    public FullSequenceNode() : base(null, NodeType.FullSequence)
    {

    }
}
