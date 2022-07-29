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
	
	list<string> gridDetail;
	
	string type <- "server";
	
	string unityMessage;
	
	list<string> selectedCell <- ["0", "0"];
	
	list<string> cellColor;
	
	int cycle;
		
	init{
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				string cellLocation <- Plot[i,j].location;
				string cellColor <- Plot[i,j].color;
				
				add "<" + cellLocation + " ; " + cellColor +">"  to: gridDetail;
			}
		}
		
		if (type = "server") {
			do CreateServer;
		}
	}
	
	reflex LiveGrid{
		if(unityMessage = "Send_Detail"){
			gridDetail <- [];
		
			loop i from: 0 to: 7{
				loop j from: 0 to: 7{
					string cellLocation <- Plot[i,j].location;
					string cellColor <- Plot[i,j].color;
					
					add "<" + cellLocation + " ; " + cellColor +">"  to: gridDetail;
				}
			}
			
		}
	}
	
	action CreateServer{
		create Server{
			do connect protocol: "tcp_server" port: 8052 raw: true;
		}
	}
	
	reflex ColorChange {
		if(unityMessage = "Send_Detail"){
			return;
		}
		else if(unityMessage = nil) {
			return;
		}
		else{
			selectedCell <- unityMessage split_with("|", false);
		}
		
		point selectedCellCoordinate;
		string selectedCellColor;
		
		selectedCellCoordinate <- selectedCell[0];
		selectedCellColor <- selectedCell[1];
		
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
	
	reflex Send{
		if(unityMessage = "Send_Detail") and (length(gridDetail) = 64){
			do send to: client contents: gridDetail;
		}
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