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
	
	int cycle;
		
	init{
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				add plot[i,j].location to: grid_location;
			}
		}
		
		if (type = "server") {
			do create_server;
		}
	}
	
	action create_server{
		create Server{
			do connect protocol: "tcp_server" port: 8052 raw: true;
		}
	}
	
	reflex colorChange {
		if(unityMessage != nil){
			selectedCell <- unityMessage split_with("|", false);
		}
		
		point selectedCellCoordinate;
		string selectedCellColor;
		
		if(selectedCell[0] != "Start"){
			selectedCellCoordinate <- selectedCell[0];
			selectedCellColor <- selectedCell[1];
		}
		
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				if(plot[i,j].location = selectedCellCoordinate){
					plot[i,j].color <- selectedCellColor;
				}
			}
		}
	}
}

species Server skills: [network] parallel:true{
	//receive message when detect message send from client 
	reflex receive when: has_more_message() {
		loop while: has_more_message() {
			message mm <- fetch_message();
			write " received : " + mm.contents color: color;
			client <- mm.sender;
			unityMessage <- mm.contents;
		}
	}
	
	reflex send when: unityMessage = "Start"{
		do send to: client contents: grid_location;
	}
}

grid plot width: 8 height: 8{
	
}

experiment run type: gui{
	output{
		display map{
			grid plot border: #black;
		}
	}
}

/* Insert your model definition here */

