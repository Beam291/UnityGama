/**
* Name: FakeBHH
* Based on the internal empty template. 
* Author: Beam291
* Tags: 
*/

model FakeBHH

global{
	//recreate code
	file gates_shape_file <- shape_file("../includes/BachHungHaiData/gates.shp");
	file rivers_shape_file <- shape_file("../includes/BachHungHaiData/rivers.shp");
	file main_rivers_shape_file <- shape_file("../includes/BachHungHaiData/main_rivers_simple.shp");
	file river_flows_shape_file <- shape_file("../includes/BachHungHaiData/river_flows.shp");
	file landuse_shape_file <- shape_file("../includes/BachHungHaiData/VNM_adm4.shp");

	graph the_river;
	geometry shape <- envelope(main_rivers_shape_file);	
	
	list<string> cells_types <- ["Aquaculture", "Rice","Vegetables", "Industrial", "Null"];
	
	map<string, rgb> cells_colors <- [cells_types[0]::#orange, cells_types[1]::#darkgreen,cells_types[2]::#lightgreen, cells_types[3]::#red, cells_types[4]::#black];
	map<string, float> cells_withdrawal <- [cells_types[0]::0.5, cells_types[1]::3.0,cells_types[2]::0.25, cells_types[3]::4.0];
	map<string, int> cells_pollution <- [cells_types[0]::55, cells_types[1]::0,cells_types[2]::20, cells_types[3]::90];
	
	bool showGrid parameter: 'Show grid' category: "Parameters" <-false;
	bool showWater parameter: 'Show Water' category: "Parameters" <-true;
	bool showLanduse parameter: 'Show LandUse' category: "Parameters" <-true; 
	bool showDryness parameter: 'Show Dryness' category: "Parameters" <-false; 
	
	bool showLegend parameter: 'Show Legend' category: "Legend" <-true;
    bool showOutput parameter: 'Show Output' category: "Legend" <-true;
	
	bool keystoning parameter: 'Show keystone grid' category: "Keystone" <-false;

	list<Gate> source;
	list<Gate> dest;
	
	map<River,float> probaEdges;
	
	float evaporationAvgTime parameter: 'Evaporation time' category: "Parameters" step: 10.0 min: 2.0 max:10000.0 <- 2500.0 ;
	float StaticPollutionEvaporationAvgTime parameter: 'Pollution Evaporation time' category: "Parameters" step: 10.0 min: 2.0 max:10000.0 <- 500.0 ;
	int grid_height <- 8;
	int grid_width <- 8;
	
	int dryness_removal_amount parameter: 'Water Evaporation time' category: "Parameters" step: 10 min: 10 max:1000 <- 100 ; 
	
	//my code
	unknown client <- nil;
	bool once <- true;
	
	list<string> gridDetail;
	
	string type <- "server";
	
	string unityMessage;
	
	list<string> selectedCell <- ["0", "0"];
	
	list<string> cellColor;
	
	int cycle;
	
	list<string> gateLocation;
	
	map<string, int> testMap <- ['A'::0, 'B'::1];
		
	init{
		//recreate
		create MainRiver from:main_rivers_shape_file{
			shape<-(simplification(shape,100));
		}
		
		create River from: rivers_shape_file;
		create Gate from: gates_shape_file with: [type:: string(read('Type'))];
		create Landuse from: landuse_shape_file with:[type::string(get("SIMPLE"))]{
			shape<-(simplification(shape,100));
		}
		
		ask Plot {
			do init_cell;
		}
		
		ask River {
			overlapping_cell <- first(Plot overlapping self);
		}
		
		the_river <- as_edge_graph(River);
		probaEdges <- create_map(River as list,list_with(length(River),100.0));
		
		ask River {
			overlapping_cell <- first(Plot overlapping self);
		}
		
		ask Landuse {
			if !empty(Plot overlapping self) {
				Plot c <- (Plot overlapping self) with_max_of(inter(each.shape,self.shape).area);
				c.landuse_on_cell <+ self;
			}
		}
		
		source <- Gate where (each.type = "source");
		dest <- Gate where (each.type = "sink");
		
		ask Gate {
			controledRivers <- River overlapping (0.4#km around self.location);
		}
		
		the_river <- as_edge_graph(River);
		probaEdges <- create_map(River as list,list_with(length(River),100.0));
		
		//old code
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				string cellColor <-	cells_colors[Plot[i,j].type];
				
				Plot[i,j].nameUnity <- "Plot"+i+j;
				
				string cellID <- ""+i+j;
				
				add "<" + cellID + " ; " + cellColor + " ; " + Plot[i,j].nameUnity + ">"  to: gridDetail;	
			}
		}
				
		write gridDetail;
		
		loop i over: get_all_instances(Gate){
			add i.location to: gateLocation;
		}
		
		if (type = "server") {
			do CreateServer;
		}
	}
	
	//get all the agent of a specie 
	list<agent> get_all_instances(species<agent> spec) {
        return spec.population +  spec.subspecies accumulate (get_all_instances(each));
    }
	
	reflex LiveGrid{
		if(unityMessage = "Send_Detail"){
			gridDetail <- [];
		
			loop i from: 0 to: 7{
				loop j from: 0 to: 7{
					string cellColor <-	cells_colors[Plot[i,j].type];
					
					Plot[i,j].nameUnity <- "Plot"+i+j;
					
					string cellID <- ""+i+j;
					
					add "<" + cellID + " ; " + cellColor + " ; " + Plot[i,j].nameUnity + ">"  to: gridDetail;
				
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
		selectedCellColor <- selectedCell[1];
		
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				if(Plot[i,j].nameUnity = selectedCellName){
					Plot[i,j].color <- selectedCellColor;
				}
			}
		}
	}
}

//river specification
species Gate {
	rgb color <- rnd_color(255);
	string Name;
	string type; // amongst "source", "sink" or "null".
	geometry shape <- circle(0.75#km);	
	bool is_closed<-false;
	list<River> controledRivers <- [];

	action take_water {
		ask (agents of_generic_species Water) overlapping self{do die;}
	}
	
	aspect base {
		if is_closed{
			draw circle(0.75#km)-circle(0.4#km) color:  #red  border: #black;
		}else{
			if self.type = "source" {
				draw circle(0.75#km) - circle(0.40#km) color:  rgb(0,162,232)  border: #black;
			}else if self.type = "sink" {
			//	draw circle(0.75#km) - circle(0.40#km) color:  #white;//  border: #black;
			}else{
				draw circle(0.75#km)-circle(0.4#km) color:  #green  border: #black;
			}
		}
	}
}

species MainRiver{
	aspect base{
		draw shape color:#blue width:2;
	}
}

species River{
	int waterLevel <- 0;
	bool is_closed <- false;
	Plot overlapping_cell;
	
	aspect base{
	  draw shape color: is_closed? #red:rgb(235-235*sqrt(min([waterLevel,8])/8),235-235*sqrt(min([waterLevel,8])/8),255) width:3;		
	}
}

species Water skills: [moving] {
	rgb color <- #blue;
	int amount<-250;
	River edge;
	float tmp;

	reflex move {	
		if edge != nil{
			tmp <- probaEdges[edge];
			put 1.0 at: edge in: probaEdges;	
		}
		do wander on: the_river speed: 450.0 proba_edges: probaEdges;
		if edge != nil{
			put tmp at: edge in: probaEdges;	
		}
		edge <- River(current_edge);
	}
	
	reflex evaporate when: (flip(1/evaporationAvgTime)){
		do die;
	}
	
	aspect default {
		if(showWater){
		  draw square(0.25#km)  color: color;		
		}
	}
}

species Landuse{
	string type;
	rgb color;
	int dryness <- 500;
	
	reflex dry when: (dryness < 1000) {
		dryness <- dryness + int(dryness_removal_amount/100);
	}
	
	aspect base{
	  if(showLanduse){
	  	
	  	if(showDryness){
	  		draw shape color:(dryness>500) ? #red :#green  border:#black;
	  	    //draw string(dryness) color:#white size:50;	
	  	}else{
	  		draw shape color:color border:#black;
	  	}
	  }	
	}
}

//Server
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

grid Plot width: 8 height: 8{
	string nameUnity;
	
	string type;
	rgb color;
	list<River> rivers_on_cell;
	list<Landuse> landuse_on_cell <- [];
	
	init {
		type<-one_of (cells_types);
	}
	
	action init_cell {
		rivers_on_cell <- River overlapping self;
	}

	aspect base{
		if(showGrid){
			if(type="Water"){
				draw circle(3 #km) color: #blue;
			}else{
			  	draw shape color:cells_colors[type];	
			}	
		}
		if keystoning {
				draw 100.0 around(shape * 0.75) color: #black;
		}
	}
}

experiment Run type: gui{
	output{
		display map  background:#black{
			species MainRiver aspect: base;
			species Gate aspect: base;
			species River aspect: base transparency: 0.2;
			species Water transparency: 0.2;
			species Plot aspect: base transparency: 0.6;
//			grid Plot border: #white transparency:0.5;
		}
	}
}