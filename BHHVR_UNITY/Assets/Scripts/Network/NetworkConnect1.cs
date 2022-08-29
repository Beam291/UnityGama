//using System;
//using System.Collections.Generic;
//using System.Net.Sockets;
//using System.Text;
//using System.Text.RegularExpressions;
//using System.Threading;
//using UnityEngine;

//public class NetworkConnect1 : MonoBehaviour
//{
//    #region internal member
//	internal string dataGama = "";
//	internal string[] listRiver = { };
//	internal bool updateNow = false;
//    #endregion

//    #region private members
//	private TcpClient socketConnection;
//	private Thread clientReceiveThread;
	
//	private const int PORT = 8053;
//	private CubeController cubeController;
//	private GenerateCube generateCube;
//	#endregion

//	// Use this for initialization 	
//	void Start()
//	{
//		ConnectToTcpServer();
//	}

//	// Update is called once per frame
//	void Update()
//	{
//        //Get the coordinate of the grid and color of it.
//        //if (Input.GetKeyDown(KeyCode.F))
//        //{
//        //    bool destroyed = false;
//        //    if (destroyed == false)
//        //    {
//        //        DestroyGameObjectsWithTag("River");
//        //        destroyed = true;
//        //    }
//        //    if (destroyed == true)
//        //    {
//        //        DetailMessage();
//        //        updateNow = true;
//        //    }
//        //}

//        DetailMessage();
//		//Prase the Data which gets from the GAMA
//		PraseData();

//        //Send the color have been selected to GAMA
//        if (Input.GetKeyDown(KeyCode.Space))
//        {
//            SendTypeMessage();
//        }
//	}

//	// Setup socket connection. 		
//	private void ConnectToTcpServer()
//	{
//		try
//		{
//			clientReceiveThread = new Thread(new ThreadStart(ListenForData));
//			clientReceiveThread.IsBackground = true;
//			clientReceiveThread.Start();
//		}
//		catch (Exception e)
//		{
//			Debug.Log("On client connect exception " + e);
//		}
//	}

//	// Runs in background clientReceiveThread; Listens for incomming data. 	
//	private void ListenForData()
//	{
//		try
//		{
//			socketConnection = new TcpClient("localhost", PORT);
//			Byte[] bytes = new Byte[1048576];
//			while (true)
//			{
//				// Get a stream object for reading 				
//				using (NetworkStream stream = socketConnection.GetStream())
//				{
//					int length;
//					// Read incomming stream into byte arrary. 					
//					while ((length = stream.Read(bytes, 0, bytes.Length)) != 0)
//					{
//						var incommingData = new byte[length];
//                        Array.Copy(bytes, 0, incommingData, 0, length);
//						// Convert byte array to string message. 	
//						string serverMes = Encoding.ASCII.GetString(incommingData);
//						dataGama = serverMes;
//						Debug.Log(dataGama);
//                    }
//				}
//			}
//		}
//		catch (SocketException socketException)
//		{
//			Debug.Log("Socket exception: " + socketException);
//		}
//	}

//	private void PraseData()
//    {
//        if (string.IsNullOrEmpty(dataGama))
//        {
//			return;
//        }
//        else
//        {
//			dataGama = dataGama.TrimStart();
//			dataGama = dataGama.TrimStart('[');
//			dataGama = dataGama.TrimEnd();
//			dataGama = dataGama.TrimEnd(']');

//            dataGama = dataGama.TrimStart('<');
//			dataGama = dataGama.TrimEnd('>');

//            string pattern = ">, <";
//            listRiver = Regex.Split(dataGama, pattern);
//		}
//    }

//	// Send detail of the gama grid to unity. 	
//	private void DetailMessage()
//	{
//		if (socketConnection == null)
//		{
//			return;
//		}
//		try
//		{
//			// Get a stream object for writing. 			
//			NetworkStream stream = socketConnection.GetStream();
//			if (stream.CanWrite)
//			{
//				string clientMessage = "Send_Detail" + "\n\r\n";
//				// Convert string message to byte array.                 
//				byte[] clientMessageAsByteArray = Encoding.ASCII.GetBytes(clientMessage);
//				// Write byte array to socketConnection stream.                 
//				stream.Write(clientMessageAsByteArray, 0, clientMessageAsByteArray.Length);
//			}
//		}
//		catch (SocketException socketException)
//		{
//			Debug.Log("Socket exception: " + socketException);
//		}
//	}
	
//	// Send the cube information which wants to change color
//	private void SendTypeMessage()
//	{
//		if (socketConnection == null)
//		{
//			return;
//		}
//		try
//		{
//			// Get a stream object for writing. 			
//			NetworkStream stream = socketConnection.GetStream();
//			if (stream.CanWrite)
//			{
//				string clientMessage = cubeController.cubeName + '|' + cubeController.cubeType + "\n\r\n";

//				// Convert string message to byte array.                 
//				byte[] clientMessageAsByteArray = Encoding.ASCII.GetBytes(clientMessage);
//				// Write byte array to socketConnection stream.                 
//				stream.Write(clientMessageAsByteArray, 0, clientMessageAsByteArray.Length);
//			}
//		}
//		catch (SocketException socketException)
//		{
//			Debug.Log("Socket exception: " + socketException);
//		}
//	}

//	//Function destroy game object
//	public static void DestroyGameObjectsWithTag(string tag)
//	{
//		GameObject[] gameObjects = GameObject.FindGameObjectsWithTag(tag);
//		foreach (GameObject target in gameObjects)
//		{
//			GameObject.Destroy(target);
//		}
//	}
//}