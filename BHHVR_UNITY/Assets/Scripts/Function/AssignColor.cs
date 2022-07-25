using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;

public class AssignColor : MonoBehaviour
{
    #region private member
    private NetworkCoordinate networkCoordinate;
    private GenerateCube generateCube;
    private string cellColor = "";
    private string[] listCellColor = { };
    private int nb_cube = 0;
    #endregion

    // Start is called before the first frame update
    void Start()
    {
        NetworkReference();
        GenerateReference();
    }

    // Update is called once per frame
    void Update()
    {
        ParseData();
        CubeColor();
    }

    private void NetworkReference()
    {
        networkCoordinate = GameObject.Find("NetworkCoordinate").GetComponent<NetworkCoordinate>();
    }

    private void GenerateReference()
    {
        generateCube = GameObject.Find("GenerateCube").GetComponent<GenerateCube>();
    }

    private void GetColor()
    {
        cellColor = networkCoordinate.gridColor;
    }

    private void ParseData()
    {

        if (string.IsNullOrEmpty(cellColor))
        {
            return;
        }
        else
        {
            cellColor = cellColor.TrimStart('[');
            cellColor = cellColor.TrimEnd();
            cellColor = cellColor.TrimEnd(']');

            string pattern = ", ";
            listCellColor = Regex.Split(cellColor, pattern);
        }
    }

    private void CubeColor()
    {
        if(listCellColor.Length == 0)
        {
            return;
        }
        else
        {

        }
    }
}
