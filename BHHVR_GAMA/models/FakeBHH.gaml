/**
* Name: FakeBHH
* Based on the internal empty template. 
* Author: Beam291
* Tags: 
*/


model FakeBHH

global{
	unknown client <- nil;
	
	list<point> grid_location;
	
	string type <- "server";
	
	point test <- "{6.25,31.25,0.0}";
	int cycle;
	
	init{
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				add plot[i,j].location to: grid_location;
				if(plot[i,j].location = test){
					write plot[i,j];
					plot[i,j].color <- #red;
				}
			}
		}
		
		//create server
		if (type = "server") {
			do create_server;
		}
		
		write grid_location[2];
	}
	
	//create server
	action create_server{
		create Server{
			do connect protocol: "tcp_server" port: 8052 raw: true;
		}
	}
}

species Server skills: [network] parallel:true{
	bool once <- true;
	
	list<string> test;
	//receive message when detect message send from client 
	reflex receive when: has_more_message() {
		loop while: has_more_message() {
			message mm <- fetch_message();
			write " received : " + mm.contents color: color;
			add mm.contents to: test;
//			write length(test);
			client <- mm.sender;
		}
		
	}
	
	reflex send {
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

