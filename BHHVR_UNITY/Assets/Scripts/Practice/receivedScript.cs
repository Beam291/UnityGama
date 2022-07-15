using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class receivedScript : MonoBehaviour
{
    public sendScript sendScriptHere;

    // Start is called before the first frame update
    void Start()
    {
        sendScriptHere = GameObject.Find("SendObject").GetComponent<sendScript>();
        Debug.Log(sendScriptHere.testNum);

    }

    // Update is called once per frame
    void Update()
    {
            
    }
}
