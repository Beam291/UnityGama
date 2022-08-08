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
        //yield on a new YieldInstruction that waits for 1 seconds.
        yield return new WaitForSeconds(1);

        //After 1 second the function will run
        CreateCube();

        //networkConnect.updateNow = false;
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

        mapPositionX = mapTable.transform.position.x;
        mapPositionY = mapTable.transform.position.y;
        mapPositionZ = mapTable.transform.position.z;

        //MapTable Focal Point
        mapFocalPointX = mapScaleX / 2;
        mapFocalPointY = mapScaleY / 2;
        mapFocalPointZ = mapScaleZ / 2;
        
        //Cell
        cellWidth = mapScaleX / 8;
        cellHeight = mapScaleY / 8;

        //Cell Focal Point
        cellFocalPointX = cellHeight/2;
        cellFocalPointY = cellHeight/2;

        //First cell - this is the first cell will foundation for others cell
        firstCellFocalPointX = (mapPositionX - mapFocalPointX) + cellFocalPointX;
        firstCellFocalPointY = (mapPositionY + mapFocalPointY) - cellFocalPointY;

        //for (float i = firstCellFocalPointX; i < (mapPositionX + mapFocalPointX); i += cellWidth)
        //{
        //    for (float j = firstCellFocalPointY; j < (mapPositionY - mapFocalPointY); j -= cellHeight)
        //    {
        //        GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
        //        Debug.Log("HI");
        //        cube.transform.position = new Vector3(
        //            i,
        //            j,
        //            0);
        //    }
        //}

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
            for (float i = firstCellFocalPointX; i < (mapPositionX + mapFocalPointX); i += cellWidth)
            {
                for (float j = firstCellFocalPointY; j > (mapPositionY - mapFocalPointY); j -= cellHeight)
                {
                    GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                    cube.transform.parent = GameObject.Find("MapTable").transform;
                    cube.transform.position = new Vector3(i, j, mapPositionZ);
                    for(int k = 0; k < networkConnect.listGridDetail.Length; k++)
                    {
                        string[] cellDetail = { };
                        string pattern = " ; ";
                        cellDetail = Regex.Split(networkConnect.listGridDetail[k], pattern);
                        string cellName = cellDetail[2];

                        cube.name = cellName;
                    }

                }
            }
            //for (int m = 0; m < 8; m++)
            //{
            //    for (int n = 0; n < 8; n++)
            //    {
            //        GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            //        GameObject mapTable = GameObject.Find("MapTable");
            //        cube.transform.parent = GameObject.Find("MapTable").transform;
            //        cube.gameObject.tag = "CubeController";
            //        //cube.name = cellName;
            //        cube.transform.position = new Vector3(
            //            0,
            //            0,
            //            0.5f);
            //    }
            //}
            for (int i = 0; i < networkConnect.listGridDetail.Length; i++)
            {
                //Handle each cell
                string[] cellDetail = { };
                string pattern = " ; ";
                cellDetail = Regex.Split(networkConnect.listGridDetail[i], pattern);

                //Get coordinate of cell
                string cellCoordinate_string = cellDetail[0];
                cellCoordinate_string = cellCoordinate_string.TrimStart('{'); 
                cellCoordinate_string = cellCoordinate_string.TrimEnd('}');
                string[] cellCoordinate_string_array = cellCoordinate_string.Split(',');
                List<float> cellCoordinate_float_list = new List<float>();
                for(int j = 0; j < cellCoordinate_string_array.Length; j++)
                {
                    float value = float.Parse(cellCoordinate_string_array[j], CultureInfo.InvariantCulture.NumberFormat);
                    cellCoordinate_float_list.Add(value);
                }
                float[] cellCoordinate = cellCoordinate_float_list.ToArray();
                
                //Get color of cell
                string cellColor_string = cellDetail[1];
                Color cellColor;
                ColorUtility.TryParseHtmlString(cellColor_string, out cellColor);

                //Get cell name
                string cellName = cellDetail[2];

                //new generate cube function
                

                //Start generate Cube
                //GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                //GameObject mapTable = GameObject.Find("MapTable");
                //cube.transform.parent = GameObject.Find("MapTable").transform;
                //cube.transform.position = new Vector3(
                //    cellCoordinate[0]/100000 - 2.8093183125f,
                //    cellCoordinate[1]/100000 , 
                //    0.5f);
                //cube.name = cellName;

                ////Set tag to the gameobject
                //cube.gameObject.tag = "CubeController";

                ////Assign color to cube
                //Renderer renderer = cube.GetComponent<Renderer>();
                //renderer.material.color = cellColor;
            }
        }
    }
}
