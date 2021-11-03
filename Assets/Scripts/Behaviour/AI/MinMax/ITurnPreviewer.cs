using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface ITurnPreviewer
{
    public TurnPreview[] GetPossibleMoves();

    public MinMaxWeights GetMinMaxWeights();
}
