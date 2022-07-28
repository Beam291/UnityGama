using System.Collections.Generic;
using System.Globalization;
using System.Text.RegularExpressions;
using UnityEngine;

public class GenerateCube : MonoBehaviour
{
    #region private member
    private NetworkConnect networkConnect;
    #endregion

    // Start is called before the first frame update
    void Start()
    {
        NetworkReference();
    }

    // Update is called once per frame
    void Update()
    {
        CreateCube();
    }

    //Reference the Network class
    private void NetworkReference()
    {
        networkConnect = GameObject.Find("NetworkConnect").GetComponent<NetworkConnect>();
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
            for(int i = 0; i < networkConnect.listGridDetail.Length; i++)
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

                //Start generate Cube
                GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                cube.transform.position = new Vector3(
                    cellCoordinate[0],
                    cellCoordinate[1],
                    cellCoordinate[2]);
                cube.transform.parent = GameObject.Find("ListOfGrid").transform;
                cube.name = "cube" + i;

                //Assign color to cube
                Renderer renderer = cube.GetComponent<Renderer>();
                renderer.material.color = cellColor;
            }
        }
    }
}
