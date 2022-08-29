//using System.Collections;
//using System.Collections.Generic;
//using System.Globalization;
//using System.Text.RegularExpressions;
//using UnityEngine;

//public class River : MonoBehaviour
//{
//    private NetworkConnect1 connect1;
//    private GameObject mapTable;
//    private float mapTableX;
//    private float mapTableY;
//    private float mapTableZ;

//    // Start is called before the first frame update
//    void Start()
//    {
//        NetworkConnect1Reference();
//        mapTableReference();
//    }

//    // Update is called once per frame
//    void Update()
//    {
//        DrawRiver();
//    }

//    private void NetworkConnect1Reference()
//    {
//        connect1 = GameObject.Find("NetworkConnect1").GetComponent<NetworkConnect1>();
//    }

//    private void mapTableReference()
//    {
//        mapTable = GameObject.Find("MapTable");
//    }

//    private void DrawRiver()
//    {
//        if(connect1.listRiver.Length == 0)
//        {
//            return;
//        }
//        else
//        {
//            mapTableX = mapTable.transform.position.x;
//            mapTableY = mapTable.transform.position.y;
//            mapTableZ = mapTable.transform.position.z;

//            for(int i = 0; i < connect1.listRiver.Length; i++)
//            {
//                string[] riverDetail = { };

//            }
//        }
//    }
//}
