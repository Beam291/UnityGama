using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using UnityEngine;

public class NetworkConnect : MonoBehaviour
{
    #region internal member
    internal string gridCoordinate = "";
	internal string gridColor = "";
	internal string gridDetail = "";
	internal string[] listGridDetail = { };
    #endregion

    #region private members
	private TcpClient socketConnection;
	private Thread clientReceiveThread;
	
	private const int PORT = 8052;
	private ControllerCube controllerCube
    {
		get;
		set;
    }
	#endregion

	// Use this for initialization 	
	void Start()
	{
		ConnectToTcpServer();
		controllerReference();
	}

	// Update is called once per frame
	void Update()
	{
        //Start the program
        if (Input.GetKeyDown(KeyCode.F))
        {
            DetailMessage();
        }

		PraseData();

        //Send the color have bene selected to GAMA
        if (Input.GetKeyDown(KeyCode.Space))
        {
            SendColorMessage();
        }

        //Get the color default from GAMA to Unity
        if (Input.GetKeyDown(KeyCode.D))
        {
			ColorReceived();
		}
	}

	private void controllerReference()
    {
		controllerCube = GameObject.Find("ControllerCube").GetComponent<ControllerCube>();
    }

	// Setup socket connection. 		
	private void ConnectToTcpServer()
	{
		try
		{
			clientReceiveThread = new Thread(new ThreadStart(ListenForData));
			clientReceiveThread.IsBackground = true;
			clientReceiveThread.Start();
		}
		catch (Exception e)
		{
			Debug.Log("On client connect exception " + e);
		}
	}

	// Runs in background clientReceiveThread; Listens for incomming data. 	
	private void ListenForData()
	{
		try
		{
			socketConnection = new TcpClient("localhost", PORT);
			Byte[] bytes = new Byte[1048576];
			while (true)
			{
				// Get a stream object for reading 				
				using (NetworkStream stream = socketConnection.GetStream())
				{
					int length;
					// Read incomming stream into byte arrary. 					
					while ((length = stream.Read(bytes, 0, bytes.Length)) != 0)
					{
						var incommingData = new byte[length];
                        Array.Copy(bytes, 0, incommingData, 0, length);
						// Convert byte array to string message. 	
						string serverMes = Encoding.ASCII.GetString(incommingData);
						gridDetail = serverMes;
                    }
				}
			}
		}
		catch (SocketException socketException)
		{
			Debug.Log("Socket exception: " + socketException);
		}
	}

	private void PraseData()
    {
        if (string.IsNullOrEmpty(gridDetail))
        {
			return;
        }
        else
        {
			gridDetail = gridDetail.TrimStart('[');
			gridDetail = gridDetail.TrimEnd();
			gridDetail = gridDetail.TrimEnd(']');
			gridDetail = gridDetail.TrimStart('<');
			gridDetail = gridDetail.TrimEnd('>');

			string pattern = ">, <";
			listGridDetail = Regex.Split(gridDetail, pattern);
		}
	}

	// Send message to server using socket connection. 	
	private void DetailMessage()
	{
		if (socketConnection == null)
		{
			return;
		}
		try
		{
			// Get a stream object for writing. 			
			NetworkStream stream = socketConnection.GetStream();
			if (stream.CanWrite)
			{
				string clientMessage = "Send_Detail" + "\n\r\n";
				// Convert string message to byte array.                 
				byte[] clientMessageAsByteArray = Encoding.ASCII.GetBytes(clientMessage);
				// Write byte array to socketConnection stream.                 
				stream.Write(clientMessageAsByteArray, 0, clientMessageAsByteArray.Length);
			}
		}
		catch (SocketException socketException)
		{
			Debug.Log("Socket exception: " + socketException);
		}
	}
	
	private void SendColorMessage()
	{
		if (socketConnection == null)
		{
			return;
		}
		try
		{
			// Get a stream object for writing. 			
			NetworkStream stream = socketConnection.GetStream();
			if (stream.CanWrite)
			{
				string clientMessage = '{'+controllerCube.cubeX + ","
					+ controllerCube.cubeY + ","
					+ controllerCube.cubeZ +'}' + '|'+ controllerCube.colorCube + "\n\r\n";
					
				// Convert string message to byte array.                 
				byte[] clientMessageAsByteArray = Encoding.ASCII.GetBytes(clientMessage);
				// Write byte array to socketConnection stream.                 
				stream.Write(clientMessageAsByteArray, 0, clientMessageAsByteArray.Length);
			}
		}
		catch (SocketException socketException)
		{
			Debug.Log("Socket exception: " + socketException);
		}
	}
	
	private void ColorReceived()
	{
		if (socketConnection == null)
		{
			return;
		}
		try
		{
			// Get a stream object for writing. 			
			NetworkStream stream = socketConnection.GetStream();
			if (stream.CanWrite)
			{
				string clientMessage = "Please_Send_Color" + "\n\r\n";
				
				// Convert string message to byte array.                 
				byte[] clientMessageAsByteArray = Encoding.ASCII.GetBytes(clientMessage);
				// Write byte array to socketConnection stream.                 
				stream.Write(clientMessageAsByteArray, 0, clientMessageAsByteArray.Length);
			}
		}
		catch (SocketException socketException)
		{
			Debug.Log("Socket exception: " + socketException);
		}
	}
}