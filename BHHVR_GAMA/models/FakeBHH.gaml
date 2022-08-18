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
		
		create Eye_candy from:river_flows_shape_file with: [type:: int(read('TYPE'))];
		
		ask Plot {
			do init_cell;
		}
		
		ask River {
			overlapping_cell <- first(Plot overlapping self);
		}
		
		the_river <- as_edge_graph(River);
		probaEdges <- create_map(River as list,list_with(length(River),100.0));
		
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
				
				ask Landuse overlapping Plot[i,j]{
			     		self.color<-cells_colors[Plot[i,j].type];
			    }
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
	
	reflex manage_water  {
		ask River {
			waterLevel <- 0;
		}
		ask Water {
			River(self.current_edge).waterLevel <- River(self.current_edge).waterLevel+1;
		}
//		ask polluted_water {
//			River(self.current_edge).waterLevel <- River(self.current_edge).waterLevel+1;
//		}
		probaEdges <- create_map(River as list, River collect(100/(1+each.waterLevel)));
		ask River where each.is_closed{
			put 0.001 at: self in: probaEdges;
		}
		ask source where(!each.is_closed){
			create Water {
				location <- myself.location;
				color<-#blue;
			}
		}
		ask dest {
			do take_water;
		}
	}
	
	action mouse_click {
		Gate selected_station <- first(Gate overlapping (circle(1) at_location #user_location));
		if selected_station != nil{
			selected_station.is_closed <- !selected_station.is_closed;
			ask selected_station.controledRivers {
				self.is_closed <- !(self.is_closed);
			}
		} else {
			Plot selected_cell <- first(Plot overlapping (circle(1) at_location #user_location));
			if selected_cell != nil{
				int old_type <- index_of(cells_types, selected_cell.type);
				selected_cell.type <- cells_types[mod(index_of(cells_types, selected_cell.type)+1,length(cells_types))];
			}
			//ask landuse overlapping selected_cell{
			ask selected_cell.landuse_on_cell{
			  self.color<-cells_colors[selected_cell.type];
			}
		}
	}
	
	//get all the agent of a specie 
	list<agent> get_all_instances(species<agent> spec) {
        return spec.population +  spec.subspecies accumulate (get_all_instances(each));
    }
	
	//The list of grid will update new change if there is a change from Unity to GAMA 
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
		string selectedCellType;
		
		selectedCellName <- selectedCell[0];
		selectedCellType <- selectedCell[1];
		
		loop i from: 0 to: 7{
			loop j from: 0 to: 7{
				if(Plot[i,j].nameUnity = selectedCellName){
					Plot[i,j].type <- selectedCellType;
					
					ask Landuse overlapping Plot[i,j]{
			     		self.color<-cells_colors[Plot[i,j].type];
			    	}
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

species polluted_water parent: Water {
	rgb color <- #red;
	string type;
	
	aspect default {
		draw square(0.25#km)  color: cells_colors[type];	
	}
}

species static_pollution{
	rgb color;
	float dissolution_expectancy;
	
	reflex remove_pollution{
		dissolution_expectancy <- dissolution_expectancy - 10;
		if dissolution_expectancy < 0 {
			do die;
		}
		
	}
	
	aspect{
		draw square(0.2#km) color: color;
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

species Eye_candy{
	int type;
	
	aspect base{
		if mod(cycle,3) = mod(type,3){
			draw shape color:#blue;
		}
		if mod(cycle-1,3) = mod(type,3){
			draw shape color:rgb(50,50,255);
		}
		if mod(cycle-2,3) = mod(type,3){
			draw shape color:rgb(100,100,255);
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
		display map  background:#white axes: true{
			species Landuse aspect:base transparency:0.65;
			species MainRiver aspect: base;
			species Gate aspect: base;
			species River aspect: base transparency: 0.2;
			species Water transparency: 0.2;
			species Plot aspect: base transparency: 0.6;
//			grid Plot border: #white transparency:0.5;

			event mouse_down action:mouse_click;
			event["g"] action: {showGrid<-!showGrid;};
			event["l"] action: {showLegend<-!showLegend;};
			event["w"] action: {showWater<-!showWater;};
			
//			graphics 'background'{
//				draw shape color:#white at:{location.x,location.y,-10};
//			}
			
			overlay position: { 180#px, 250#px } size: { 180 #px, 100 #px } background:#black transparency: 1 rounded: true
            {   
            	if(showLegend){
// previous overlay, kept for rolling back
//            		float x <- -70#px;
//					float y <- -203#px;
//	            	draw "CityScope Hanoi" at: { x, y } color: #white font: font("Helvetica", 32,#bold);
//	            	draw "\nWater Management" at: { x, y } color: #white font: font("Helvetica", 20,#bold);
//		            
					float x <- -70#px;
					float y <- -150#px;
		            draw "CityScope" at: { x, y } color: #black font: font("Helvetica", 32,#bold);
		            draw "\nHanoi" at: { x, y+35#px } color: #black font: font("Helvetica", 32,#bold);
	            	draw "\n\nWater Management" at: { x, y + 70#px } color: #black font: font("Helvetica", 17,#bold);
	            	
	            	y <- 190#px;
	            	draw "INTERACTION" at: { x,  y } color: #black font: font("Helvetica", 20,#bold);
	            	y<-y+25#px;
	            	draw "Landuse" at: { x,  y } color: #black font: font("Helvetica", 20,#bold);
	            	y<-y+25#px;
	            	
	                loop type over: cells_types where (each != "Null")
	                {
//	                    draw square(20#px) at: { x + 10#px, y } color: #white;
//						loop i from: 0 to: lego_code[type].rows - 1{
//							loop j from: 0 to: lego_code[type].columns - 1{
//								draw square(8#px) at: {x + (5+i*10)#px, y + (-5+j*10)#px} color: lego_code[type][i,j]=1?#black:#white;
//							}
//						}
	                    draw square(20#px) at: { x, y } color: cells_colors[type] border: cells_colors[type]+1;
	                    draw string(type) at: { x + 20#px, y + 7#px } color: #black font: font("Helvetica", 20,#bold);
	                    y <- y + 25#px;
	                }
	                
	                y <- y + 40#px;
	                draw "Gate" at: { x + 0#px,  y+7#px } color: #black font: font("Helvetica", 20,#bold);
	            	y <- y + 25#px;
	                draw circle(10#px)-circle(5#px) at: { x + 20#px, y } color: #green border: #black;
	                draw 'Open' at: { x + 40#px, y + 7#px } color: #black font: font("Helvetica", 20,#bold);
	                y <- y + 25#px;
	                draw circle(10#px)-circle(5#px) at: { x + 20#px, y } color: #red border: #black;
	                draw 'Closed' at: { x + 40#px, y + 7#px } color: #black font: font("Helvetica", 20,#bold);
	                y <- y + 25#px;
	                draw circle(10#px)-circle(5#px) at: { x + 20#px, y } color: rgb(0,162,232) border: #black;
	                draw 'Source' at: { x + 40#px, y + 7#px } color: #black font: font("Helvetica", 20,#bold);
//	                y <- y + 25#px;
//	                draw circle(10#px)-circle(5#px) at: { x + 20#px, y } color: #white border: #black;
//	                draw 'Sink' at: { x + 40#px, y + 7#px } color: #white font: font("Helvetica", 20,#bold);
	                y <- y + 25#px;
//	                draw "Turn lego to open" at: { x + 0#px,  y+4#px } color: #white font: font("Helvetica", 20,#bold);
//	            	draw "\nand close" at: { x + 0#px,  y+4#px } color: #white font: font("Helvetica", 20,#bold);
	            
            	}	
            }
		}
	}
}