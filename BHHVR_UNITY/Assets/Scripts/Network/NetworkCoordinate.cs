using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using UnityEngine;

public class NetworkCoordinate : MonoBehaviour
{
	public string gridCoordinate = "";

	

	#region private members 	
	private TcpClient socketConnection;
	private Thread clientReceiveThread;
	private const int PORT = 8052;
	#endregion

	// Use this for initialization 	
	void Start()
	{
		ConnectToTcpServer();
	}

	// Update is called once per frame
	void Update()
	{
		SendMessage();
		List<string> test = new List<string>();
		test.Add(gridCoordinate);
		Debug.Log(test.Count);
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
						gridCoordinate = serverMes;
						
					}
				}
			}
		}
		catch (SocketException socketException)
		{
			Debug.Log("Socket exception: " + socketException);
		}
	}

	//split the data
	private void splitMes(string mes)
	{
		int start = mes.IndexOf('[');
		int end = mes.IndexOf("]");

		mes = mes.Substring(start + 1, end - 1);

		mes = mes.TrimStart('{');
		mes = mes.TrimEnd('}');
		string pattern = "}, {";
		string[] result = Regex.Split(mes, pattern);

	}

	// Send message to server using socket connection. 	
	private void SendMessage()
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
				string clientMessage = "Start" + "\n\r\n";
				// Convert string message to byte array.                 
				byte[] clientMessageAsByteArray = Encoding.ASCII.GetBytes(clientMessage);
				// Write byte array to socketConnection stream.                 
				stream.Write(clientMessageAsByteArray, 0, clientMessageAsByteArray.Length);

				//Debug.Log("Client sent his message - should be received by server");
			}
			//stream.Close();
		}
		catch (SocketException socketException)
		{
			Debug.Log("Socket exception: " + socketException);
		}
	}
}