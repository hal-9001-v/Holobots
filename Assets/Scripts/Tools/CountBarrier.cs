using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CountBarrier
{
    int counter;

    Action _barrierAction;

    public CountBarrier(Action action)
    {
        counter = 0;

        _barrierAction = action;
    }

    public void AddCounter()
    {
        counter++;
    }

    public void RemoveCounter()
    {
        if (counter == 0)
        {
            Debug.LogWarning("Barrier was reduced when it was 0 in counter!");
        }

        counter--;

        if (counter == 0)
        {
            _barrierAction.Invoke();
        }
    }

}
