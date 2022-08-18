using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CubeController : MonoBehaviour
{
    #region private member
    private GenerateCube generateCube;
    #endregion

    #region internal member
    internal string cubeX;
    internal string cubeY;
    internal string cubeZ;

    internal string cubeName;
    internal string cubeType
    {
        get;
        set;
    }
    #endregion

    // Start is called before the first frame update
    void Start()
    {
        GenerateCubeReference();

        //"Aquaculture", "Rice","Vegetables", "Industrial", "Null"
        cubeType = "Aquaculture";
    }

    // Update is called once per frame
    void Update()
    {
        //When the mouse is clicked it will get the information of 
        if (Input.GetMouseButtonDown(0))
        {
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            if (Physics.Raycast(ray, out hit))
            {
                if (hit.collider.tag == "CubeController")
                {
                    cubeName = hit.collider.gameObject.transform.name;
                }
            }
        }

    }

    private void GenerateCubeReference()
    {
        generateCube = GameObject.Find("GenerateCube").GetComponent<GenerateCube>();
    }
}
