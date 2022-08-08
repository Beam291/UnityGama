using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MapTable : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GameObject cubemap = GameObject.Find("MapTable");
        Debug.Log(cubemap.transform.localScale);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
