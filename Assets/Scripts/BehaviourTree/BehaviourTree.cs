using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BehaviourTree
{
    public BehaviourNode root;

    Stack<BehaviourNode> _nodesForExecution;

    Action _endOfExecutionAction;

    public BehaviourTree()
    {
        _nodesForExecution = new Stack<BehaviourNode>();
    }

    public bool ExecuteNode(BehaviourNode node)
    {
        //Execute next Nodes
        switch (node.nodeType)
        {
            case NodeType.Leaf:
                return node.Execute();

            case NodeType.WaitForTick:
                AddNodesForExecution(node.children);
                return true;

            case NodeType.FullSequence:
                AddNodesForExecution(node.children);

                Tick();
                break;

            case NodeType.Sequence:
                foreach (var child in node.children)
                {
                    if (ExecuteNode(child) == false)
                    {
                        return false;
                    }
                }

                return true;

            case NodeType.Selector:

                foreach (var child in node.children)
                {
                    if (ExecuteNode(child))
                    {
                        return true;
                    }
                }

                return false;

            case NodeType.WaiterSelector:
                break;

        }

        return true;
    }

    public void Tick()
    {
        if (_nodesForExecution.Count > 0)
        {
            ExecuteNode(_nodesForExecution.Pop());
        }
        else
        {
            if (_endOfExecutionAction != null)
                _endOfExecutionAction.Invoke();
        }
    }

    public void StartTree(Action afterTreeExecutionAction)
    {
        _endOfExecutionAction = afterTreeExecutionAction;

        ExecuteNode(root);
    }

    public void StartTree()
    {
        _nodesForExecution.Clear();

        ExecuteNode(root);
    }

    void AddNodesForExecution(List<BehaviourNode> nodes)
    {
        foreach (var node in nodes)
        {
            _nodesForExecution.Push(node);
        }
    }

}
