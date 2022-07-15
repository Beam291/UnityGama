using System.Collections.Generic;
using System.Globalization;
using System.Text.RegularExpressions;
using UnityEngine;

public class GenerateCube : MonoBehaviour
{
    private NetworkCoordinate networkCoordinate;

    private string cubeCoordinate = "";
    internal string[] listCubeCoordinate = { };

    private bool isDone = false;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        GetCoordinate();
        ParseData();
        if (isDone == false && listCubeCoordinate.Length != 0)
        {
            createCube();
            isDone = true;
        }
    }

    //get Coordinate from network
    private void GetCoordinate()
    {
        networkCoordinate = GameObject.Find("NetworkCoordinate").GetComponent<NetworkCoordinate>();
        cubeCoordinate = networkCoordinate.gridCoordinate;
    }

    //Parse Data to use
    private void ParseData()
    {
        if (string.IsNullOrEmpty(cubeCoordinate))
        {
            return;
        }
        else
        {   
            cubeCoordinate = cubeCoordinate.TrimStart('[');
            cubeCoordinate = cubeCoordinate.TrimStart('{');
            cubeCoordinate = cubeCoordinate.TrimEnd();
            cubeCoordinate = cubeCoordinate.TrimEnd(']');
            cubeCoordinate = cubeCoordinate.TrimEnd('}');

            string pattern = "}, {";
            listCubeCoordinate = Regex.Split(cubeCoordinate, pattern);
        }
    }

    private void createCube()
    {
        if (listCubeCoordinate.Length == 0)
        {
            return;
        }
        else
        {
            for (int i = 0; i < listCubeCoordinate.Length; i++)
            {
                GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                string[] subStringList = listCubeCoordinate[i].Split(',');

                List<float> listFloat = new List<float>();
                for (int j = 0; j < subStringList.Length; j++)
                {
                    float value = float.Parse(subStringList[j], CultureInfo.InvariantCulture.NumberFormat);
                    listFloat.Add(value);
                }

                float[] subFloatList = listFloat.ToArray();

                //assgin position to cube
                cube.transform.position = new Vector3(
                    subFloatList[0],
                    subFloatList[2],
                    subFloatList[1]);

                cube.transform.parent = GameObject.Find("ListOfGrid").transform;
                cube.name = "cube" + i;
            }
        }
    }
}
