using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Text_Button_1 : MonoBehaviour
{
    // Start is called before the first frame update
    private CubeController cubeController;

    public void SelectColor()
    {
        cubeController = GameObject.Find("CubeController").GetComponent<CubeController>();
        cubeController.colorCube = "red";
    }
}
