using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Text.RegularExpressions;
using UnityEngine;

public class GenerateCube : MonoBehaviour
{
    #region internal member
    internal bool createCell;
    #endregion

    #region private member
    private NetworkConnect networkConnect;

    //Specification of MapTable
    private float mapScaleX;
    private float mapScaleY;
    private float mapScaleZ;

    private float mapPositionX;
    private float mapPositionY;
    private float mapPositionZ;

    private float mapFocalPointX;
    private float mapFocalPointY;
    private float mapFocalPointZ;

    //Specification of a cell
    float cellWidth;
    float cellHeight;

    float cellFocalPointX;
    float cellFocalPointY;

    float firstCellFocalPointX;
    float firstCellFocalPointY;
    #endregion

    // Start is called before the first frame update
    void Start()
    {
        MeasureCube();
        NetworkReference();
    }

    // Update is called once per frame
    void Update()
    {
        if (networkConnect.updateNow == true)
        {
            StartCoroutine(WaitingForTCPConnected());

            networkConnect.updateNow = false;
        }
    }

    IEnumerator WaitingForTCPConnected()
    {
        //yield on a new YieldInstruction that waits for 3 seconds.
        yield return new WaitForSeconds(3);

        //After 3 second the function will run
        CreateCube();
    }

    //Reference the Network class
    private void NetworkReference()
    {
        networkConnect = GameObject.Find("NetworkConnect").GetComponent<NetworkConnect>();
    }

    private void MeasureCube()
    {
        //MapTable
        GameObject mapTable = GameObject.Find("MapTable");
        mapScaleX = mapTable.transform.localScale.x;
        mapScaleY = mapTable.transform.localScale.y;
        mapScaleZ = mapTable.transform.localScale.z;

        //Map table postion
        mapPositionX = mapTable.transform.position.x;
        mapPositionY = mapTable.transform.position.y;
        mapPositionZ = mapTable.transform.position.z;

        //MapTable Focal Point
        mapFocalPointX = mapScaleX / 2;
        mapFocalPointY = mapScaleY / 2;
        mapFocalPointZ = mapScaleZ / 2;
        
        //Cell width and height
        cellWidth = mapScaleX / 8;
        cellHeight = mapScaleY / 8;

        //Cell Focal Point
        cellFocalPointX = cellHeight/2;
        cellFocalPointY = cellHeight/2;

        //First cell - this is the first cell will foundation for others cell
        firstCellFocalPointX = (mapPositionX - mapFocalPointX) + cellFocalPointX;
        firstCellFocalPointY = (mapPositionY + mapFocalPointY) - cellFocalPointY;
    }

    //Create Cube
    private void CreateCube()
    {
        if (networkConnect.listGridDetail.Length == 0)
        {
            return;
        }
        else
        {
            //new generate cube depend on the maptable has already created
            for (float i = firstCellFocalPointX; i < (mapPositionX + mapFocalPointX); i += cellWidth)
            {
                for (float j = firstCellFocalPointY; j > (mapPositionY - mapFocalPointY); j -= cellHeight)
                {
                    GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube); // create new cube

                    cube.transform.parent = GameObject.Find("CubeManagement").transform; // Find the map table

                    cube.transform.position = new Vector3(i, j, mapPositionZ); //assign the position to concur with the grid in GAMA

                    cube.name = "CubeNoName"; //default name, it will be change later
                    
                    cube.gameObject.tag = "CubeController"; //add tag to each cube

                    cube.transform.localScale = new Vector3(0.06f, 0.06f, 2f); // modify the scale of the cube
                }
            }

            //Assign Name and color for the cube
            for (int i = 0; i < 8; i++)
            {
                for(int j = 0; j < 8; j++)
                {
                    //Assign name that concur with the name from nameUnity in GAMA
                    GameObject cube = GameObject.Find("CubeNoName");
                    cube.name = "Plot" + i + j;
                    string cubeID = "" + i + j;

                    //Assign color to the cube
                    for (int k = 0; k < networkConnect.listGridDetail.Length; k++)
                    {
                        string[] cellDetail = { };
                        string pattern = " ; ";
                        cellDetail = Regex.Split(networkConnect.listGridDetail[k], pattern);

                        if (cubeID == cellDetail[0])
                        {
                            string cellColor_string = cellDetail[1];
                            Color cellColor;
                            Renderer renderer = cube.GetComponent<Renderer>();
                            //Each type of cell will be assign to a different color
                            switch (cellColor_string)
                            {
                                case "orange":
                                    ColorUtility.TryParseHtmlString(cellColor_string, out cellColor);
                                    renderer.material.color = cellColor;
                                    break;
                                case "darkgreen":
                                    cellColor = new Color(1f / 255f, 50f / 255f, 32f / 255f);
                                    renderer.material.color = cellColor;
                                    break;
                                case "lightgreen":
                                    cellColor = new Color(144f/255f, 238f / 255f, 144f/255f);
                                    renderer.material.color = cellColor;
                                    break;
                                case "red":
                                    ColorUtility.TryParseHtmlString(cellColor_string, out cellColor);
                                    renderer.material.color = cellColor;
                                    break;
                                case "black":
                                    ColorUtility.TryParseHtmlString(cellColor_string, out cellColor);
                                    renderer.material.color = cellColor;
                                    break;
                            }
                        }
                    }
                }
            }
        }
    }
}
