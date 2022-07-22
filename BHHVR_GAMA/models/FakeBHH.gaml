/**
* Name: FakeBHH
* Based on the internal empty template. 
* Author: Beam291
* Tags: 
*/

model FakeBHH

global{
	unknown client <- nil;
	bool once <- true;
	
	list<point> grid_location;
	
	string type <- "server";
	
	string unityMessage;
	
	list<string> selectedCell <- ["0", "0"];
	
	list<string> cellColor;
	
	int cycle;
		
	init{
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				add Plot[i,j].location to: grid_location;
				add Plot[i,j].color to: cellColor;
			}
		}
		
		write cellColor;
		
		if (type = "server") {
			do CreateServer;
		}
	}
	
	action CreateServer{
		create Server{
			do connect protocol: "tcp_server" port: 8052 raw: true;
		}
	}
	
	reflex ColorChange {
		if(unityMessage != nil){
			selectedCell <- unityMessage split_with("|", false);
		}
		
		point selectedCellCoordinate;
		string selectedCellColor;
		
		if(selectedCell[0] != "Start" or selectedCell[0] != "Please_Send_Color"){
			selectedCellCoordinate <- selectedCell[0];
			selectedCellColor <- selectedCell[1];
		}
		
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				if(Plot[i,j].location = selectedCellCoordinate){
					Plot[i,j].color <- selectedCellColor;
				}
			}
		}
	}
}

species Server skills: [network] parallel:true{
	//receive message when detect message send from client 
	reflex Receive when: has_more_message() {
		loop while: has_more_message() {
			message mm <- fetch_message();
			write " received : " + mm.contents color: color;
			client <- mm.sender;
			unityMessage <- mm.contents;
		}
	}
	
	reflex Send when: unityMessage = "Start"{
		do send to: client contents: grid_location;
	}
	
	reflex Send_1 when: unityMessage = "Please_Send_Color"{
		do send to: client contents: cellColor;
	}
}

grid Plot width: 8 height: 8{
	init{
		one_of(Plot).color <- #green;
	}
}

experiment Run type: gui{
	output{
		display map{
			grid Plot border: #black;
		}
	}
}