/**
* Name: RoadTraffic
* Based on the internal empty template. 
* Author: Beam291
* Tags: 
*/


model RoadTraffic

//There only 1 server (for the moment) so it will has network on global
global skills: [network]{
	
	unknown client <- nil;
	
	shape_file buildings_shape_file <- shape_file("../includes/buildings.shp");
	shape_file roads_shape_file <- shape_file("../includes/roads.shp");
	geometry shape <- envelope(roads_shape_file);
	float people_m2 <- 0.001;
	float step <- 10#s;
	graph road_network;
	map<road,float> road_weights;
	
	list<point> people_location;
	int nb_people;
	int cycle;
	
	init{
		create building from: buildings_shape_file with:[height::int(read("HEIGHT"))];
		create road from: roads_shape_file;
		ask building{
			int num_to_create <- round(people_m2 * shape.area);
			create inhabitant number: num_to_create{
			location <- any_location_in(one_of(building));
			}
		}
		road_network <- as_edge_graph(road);
		
		//connect network
		do connect protocol: "tcp_server" port: 8052 raw: true;
		
		//get the location of each agent in specie
		loop i over: get_all_instances(inhabitant){
			add i.location to: people_location;
		}
		
		nb_people <- length(people_location);
		
	}
	
	bool first_time <- true;
	
	//refex to send message from server to client
	reflex send_reflex{
		loop i over: people_location{
			do send to:client contents: i;
		}
//		do send to: client contents: people_location;
//		do send to: client contents: nb_people;
	}
	
	//user detemine when they will send
	user_command send {
		do send to: client contents: first(people_location);
	}
	
	//message recieve from unity
	reflex receive when: has_more_message() {
		loop while: has_more_message() {
			message mm <- fetch_message();
			write name + " received : " + mm.contents ;
			client <- mm.sender;
		}

	}
	
	//get list of agent of a specific specie
	list<agent> get_all_instances(species<agent> spec) {
        return spec.population +  spec.subspecies accumulate (get_all_instances(each));
    }
	
	reflex update_weights{
		road_weights <- road as_map (each::each.shape.perimeter/each.speed_rate);
	}
}

grid pollution_cell width: 50 height: 50{
	
	reflex decrease_pollution when: every(1 #h){
		grid_value <- grid_value * 0.9;
	}
}

species road{
	float capacity <- 1+ shape.perimeter /30;
	int nb_drivers <- 0 update: length(inhabitant at_distance 1);
	float speed_rate <- 1.0 update: exp(-nb_drivers/ capacity)min: 0.1;
	aspect default{
		draw (shape+3*speed_rate) color: #red;
	}
}

species building{
	int height;
	aspect default{
		draw shape color: #gray;
	}
	
	aspect threeD{
		draw shape color: #gray depth: height texture: ["../includes/roof.png","../includes/texture5.jpg"];
	}
}

species inhabitant skills: [moving]{
	point target;
	rgb color <- rnd_color(255);
	float proba_leave <- 0.05;
	float speed <- 5 #km/#h;
	float pollution_produced <- rnd(90.0,250.0);
	
	aspect default{
		draw circle(5) color: color;
	}
	
	reflex leave when: (target= nil) and (flip(proba_leave)){
		target <- any_location_in(one_of(building));
	}
	
	reflex move when: target != nil{
		do goto target: target on: road_network move_weights: road_weights;
		if(location = target){
			target <- nil;
		}else{
			pollution_cell my_cell <- pollution_cell(location);
			my_cell.grid_value <- my_cell.grid_value + pollution_produced;
		}
	}
	
	aspect threeD{
		draw pyramid(4) color: color;
		draw sphere(1) at: location + {0,0,4} color: color;
	}
}

experiment runRoadTraffic{
	output{
//		display map3D type: opengl{
//			image "../includes/satellite.jpg" refresh: false;
//			species inhabitant aspect: threeD;
//			species building aspect: threeD;
//		}

		display roadTraffic type: opengl{
//			mesh pollution_field grayscale: true scale: 0.05 triangulation: true smooth: true;
//			mesh pollution_cell transparency: 0.5 color: #red scale: 0.05 triangulation: true smooth: true;
			species road aspect: default;
			species building aspect: default;
			species inhabitant aspect: default;
		}
	}
}