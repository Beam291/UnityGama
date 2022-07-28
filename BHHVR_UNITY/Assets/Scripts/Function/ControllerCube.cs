using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControllerCube : MonoBehaviour
{
    #region private member
    private int nb_cube;

    private GenerateCube generateCube;
    #endregion

    #region internal member
    internal string cubeName;
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

            if(Physics.Raycast(ray, out hit))
            {
                if(hit.collider != null)
                {
                    if(hit.collider.tag == "CubeController")
                    {
                        Debug.Log("Clicked");
                    }
                    //Debug.Log(hit.collider.tag);
                    cubeName = hit.transform.gameObject.name; 
                    float x = hit.transform.gameObject.transform.position.x;
                    cubeX = x.ToString("0.00");
                    float y = hit.transform.gameObject.transform.position.y;
                    cubeY = y.ToString("0.00");
                    float z = hit.transform.gameObject.transform.position.z;
                    cubeZ = z.ToString("0.00");
                }
            }
        }

    }

    void OnMouseDown()
    {
        // Destroy the gameObject after clicking on it
        Destroy(gameObject);
    }

    private void GenerateCubeReference()
    {
        generateCube = GameObject.Find("GenerateCube").GetComponent<GenerateCube>();
    }

    //private void GetListOfCube()
    //{
    //    generateCube = GameObject.Find("GenerateCube").GetComponent<GenerateCube>();
    //    if (generateCube.listCubeCoordinate.Length == 0)
    //    {
    //        return;
    //    }
    //    else
    //    {
    //        nb_cube = generateCube.listCubeCoordinate.Length;
    //    }
    //}

    //private void OnMouseDown()
    //{
    //    Destroy(this.gameObject);
    //}
}
