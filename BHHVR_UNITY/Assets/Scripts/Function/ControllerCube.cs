using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControllerCube : MonoBehaviour
{
    private int nb_cube;

    private GenerateCube generateCube;
    string cubeName;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        GetListOfCube();
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            if(Physics.Raycast(ray, out RaycastHit hitInfo))
            {
                if(hitInfo.transform != null)
                {
                    cubeName = hitInfo.transform.gameObject.name;
                    Debug.Log(hitInfo.transform.gameObject.transform.position);
                }
            }
        }
        
    }

    private void GetListOfCube()
    {
        generateCube = GameObject.Find("GenerateCube").GetComponent<GenerateCube>();
        if (generateCube.listCubeCoordinate.Length == 0)
        {
            return;
        }
        else
        {
            nb_cube = generateCube.listCubeCoordinate.Length;
        }
    }

    private void onMouseDown()
    {
        Destroy(this.gameObject);
    }
}
