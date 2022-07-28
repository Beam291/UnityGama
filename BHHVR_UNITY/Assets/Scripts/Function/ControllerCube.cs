using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControllerCube : MonoBehaviour
{
    #region private member
    private GenerateCube generateCube;
    #endregion

    #region internal member
    internal string cubeX;
    internal string cubeY;
    internal string cubeZ;
    internal string colorCube
    {
        get;
        set;
    }
    #endregion

    // Start is called before the first frame update
    void Start()
    {
        GenerateCubeReference();
    }

    // Update is called once per frame
    void Update()
    {
        //GetListOfCube();
        if (Input.GetMouseButtonDown(0))
        {
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            if (Physics.Raycast(ray, out hit))
            {
                if (hit.collider.tag == "CubeController")
                {
                    float x = hit.collider.gameObject.transform.position.x;
                    cubeX = x.ToString("0.00");
                    float y = hit.transform.gameObject.transform.position.y;
                    cubeY = y.ToString("0.00");
                    float z = hit.transform.gameObject.transform.position.z;
                    cubeZ = z.ToString("0.00");
                }
            }
        }

    }

    private void GenerateCubeReference()
    {
        generateCube = GameObject.Find("GenerateCube").GetComponent<GenerateCube>();
    }
}
