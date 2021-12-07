using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SequenceNode : BehaviourNode
{
    public SequenceNode(BehaviourNode parent) : base(parent, null, NodeType.Sequence)
    {

    }

    public SequenceNode() : base(null, NodeType.Sequence)
    {

    }
}
