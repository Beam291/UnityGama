using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Null_Button : MonoBehaviour
{
    // Start is called before the first frame update
    private CubeController cubeController;

    public void SelectCubeType()
    {
        cubeController = GameObject.Find("CubeController").GetComponent<CubeController>();
        cubeController.cubeType = "Null";
    }
}
