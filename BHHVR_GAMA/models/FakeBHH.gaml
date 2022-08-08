/**
* Name: FakeBHH
* Based on the internal empty template. 
* Author: Beam291
* Tags: 
*/

model FakeBHH

global{
	shape_file riverShapeFile <- shape_file("../includes/BHH_File/rivers.shp");
	shape_file gateShapeFile <- shape_file("../includes/BHH_File/gates.shp");

	geometry shape <- envelope(riverShapeFile);

	unknown client <- nil;
	bool once <- true;
	
	list<string> gridDetail;
	
	string type <- "server";
	
	string unityMessage;
	
	list<string> selectedCell <- ["0", "0"];
	
	list<string> cellColor;
	
	int cycle;
	
	list<string> gateLocation;
	
	list<string> sendMes;
		
	init{
		create River from: riverShapeFile;
		create Gate from: gateShapeFile;
		
		write shape.location;
		write shape.height/10000;
		write shape.width/10000;
		
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				string cellLocation <- Plot[i,j].location;
				string cellColor <- Plot[i,j].color;
				string cellName <- Plot[i,j].name;
				
				add "<" + cellLocation + " ; " + cellColor + " ; " + cellName + ">"  to: gridDetail;
				write Plot[0,0].name;
				write Plot[0,1].name;
				Plot[0,2].color <- #red;
			}
		}
		
		loop i over: get_all_instances(Gate){
			add i.location to: gateLocation;
		}
		
		
		
		if (type = "server") {
			do CreateServer;
		}
	}
	
	list<agent> get_all_instances(species<agent> spec) {
        return spec.population +  spec.subspecies accumulate (get_all_instances(each));
    }
	
	reflex LiveGrid{
		if(unityMessage = "Send_Detail"){
			gridDetail <- [];
		
			loop i from: 0 to: 7{
				loop j from: 0 to: 7{
					string cellLocation <- Plot[i,j].location;
					string cellColor <- Plot[i,j].color;
					string cellName <- Plot[i,j].name;
					
					add "<" + cellLocation + " ; " + cellColor + " ; " + cellName +  ">"  to: gridDetail;
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
		string selectedCellName;
		string selectedCellColor;
		
		selectedCellName <- selectedCell[0];
//		selectedCellCoordinate <- selectedCell[0];
		selectedCellColor <- selectedCell[1];
		
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				if(Plot[i,j].name = selectedCellName){
					Plot[i,j].color <- selectedCellColor;
				}
			}
		}
	}
}

species Gate {
	aspect default{
		draw circle(0.5#km) color: #red border: #black;
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
			do send to: client contents: gridDetail + '1' + gateLocation;
		}
	}
}

species River{
	aspect base{
		draw (shape) color: #black;
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
			species Gate aspect: default;
			species River aspect: base;
			grid Plot border: #black transparency:0.5;
		}
	}
}