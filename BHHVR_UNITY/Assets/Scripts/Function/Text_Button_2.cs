using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Text_Button_2 : MonoBehaviour
{
    // Start is called before the first frame update
    private ControllerCube controllerCube;

    public void SelectColor()
    {
        controllerCube = GameObject.Find("ControllerCube").GetComponent<ControllerCube>();
        controllerCube.colorCube = "blue";
    }
}
