using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public  class SelectionArrow : MonoBehaviour
{
    
    [SerializeField] GameObject arrow;
    private GameObject fatherGO; 
    
    private void Awake() {

        fatherGO = null;

    }
    public void SetPosition(GameObject g){

        fatherGO = g;

    }

    private void Update() {
        if(fatherGO!=null) this.gameObject.transform.position = new Vector3(fatherGO.transform.position.x, 3.5f,fatherGO.transform.position.z);
    }
    
}
