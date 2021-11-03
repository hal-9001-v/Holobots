using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GridLineProvider : MonoBehaviour
{
    [SerializeField] GridLine _movementGridLinePrototype;
    [SerializeField] GridLine _attackGridLinePrototype;

    public GridLine CloneMovementGridLine(string ownerName)
    {
        var gridLine = CloneGridLine(_movementGridLinePrototype);
        gridLine.name = ownerName + "'s movement Grid Line";


        return gridLine;
    }
    public GridLine CloneAttacktGridLine(string ownerName)
    {
        var gridLine = CloneGridLine(_attackGridLinePrototype);
        gridLine.name = ownerName + "'s Attack Grid Line";

        return gridLine;
    }

    GridLine CloneGridLine(GridLine prototype)
    {
        var newGridLine = Instantiate(prototype.gameObject);

        newGridLine.transform.position = prototype.transform.position;
        newGridLine.transform.parent = prototype.transform.parent;

        return newGridLine.GetComponent<GridLine>();
    }

}
